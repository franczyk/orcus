class CommandsController < ApplicationController
    DEBUG=1
    RUNEVERYTIME=0

  def show
    hostname = Host.find_by_name(params[:id])
    h = hostname

    if h.nil?
      h = Host.create
      h.name = hostname
      h.save
    end
    h.last_checkin = Time.now
    h.save

    begin
      if h.pools.count > 0
        if h.pools.any? 
          h.pools.each do |p|
            CheckAllActions(p)
          end
        end
      end
    rescue
      puts "Caught some crazy issue!" + $! if DEBUG == 1
    end

    @host = h
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @host }
    end
  end

end

# TO DO:
# Make a chain type that references ANOTHER existing chain. (to allow nesting)
# Or, allow chains to reference the Automations table (which is not as good)


###################################

def getTopParent(ci)
  parent = ci
  if ci.parents.any?
    ci.parents.each do |p|
      parent=p
      parent = getTopParent(parent)
    end
  end
  
  return parent
end


###################################
def ArchiveChainInstanceTree(ci)

  children = ci.children
  puts "archiving : " + ci.id.to_s if DEBUG == 1
  ci.completed = true
  ci.save
  
  children.each do |child|
    ArchiveChainInstanceTree(ci)
  end
  return
end

###################################
def runChainInstance(ci, retrynumber)
  puts "Running command: " + ci.chain.action.command if DEBUG == 1
  rc = system(ci.chain.action.command)  
  if rc
    ci.status = true
    ci.save
    return true
  else
    
    if retrynumber.nil? 
      retrynumber=0
    else
      retrynumber=retrynumber + 1 
    end
    
    if retrynumber >= ci.chain.retries
      ci.status = false
      ci.save
      return false
    else
      runChainInstance(ci, retrynumber)
    end
    
  end
end

###################################
def runChildren(ci)
  puts "looking for children: " + ci.id.to_s if DEBUG == 1
  ci.chain.children.each do |child|
    if child.action.pool.hosts.find_by_name(hostname)
      childinstance = child.chain_instances.create
      childinstance.starttime = Time.now
      childinstance.timeout = child.timeout
      childinstance.save
      runChainInstance(ci,0)
    end
  end
end

###################################
def runFalseChild(ci)
  puts "finding false child."
  ci.children.each do |cic|
    puts "checking " if DEBUG == 1
    if cic.chain.precondition == 0 
      return runChainInstance(cic,0)
    end
  end
end


###################################
def RunAllBottomEntries(ci)
  puts "Running all bottom entries." if DEBUG == 1
  if isOpen(ci)
    # dont touch this one cause its waiting to complete.
    puts "It is still running.  Waiting for it to time out or complete: " + ci.chain.action.command if DEBUG == 1
  elsif isTimedOut(ci)
    puts "Timed out: " + ci.id.to_s if DEBUG == 1
    ci.completedtime = Time.now
    ci.status = 0
    ci.save
    runFalseChild(ci)
    ransomething = true
  else
    puts "Not timed out, not open.  Closed: " + ci.id.to_s if DEBUG == 1
    if ci.children.any?
      puts "There are children: " + ci.id.to_s if DEBUG == 1
      ci.children.each do |child|
        if child.chain.precondition == ci.status
          rc = RunAllBottomEntries(child)
          if ransomething == false and rc == true
            ransomething = true
          end
        end
      end
    else
      if ci.chain.children.any?  # is there a situation that where THIS task would need to run?  possibly.
        runChildren(ci)
        ransomething = true
      end
    end
  end

  puts "ransomething is set to... '" + ransomething.to_s + "'" if DEBUG == 1
  return ransomething
end

###################################
def FindChild(ci, success)
  if ci.children.any? 
    # There are instances of children that have started (and may have finished)
  	ci.children.each do |child|
  		if child.chain.precondition == success 
  			return child  # I need to return multiple children, because multiple children can run on true/false.
  		end
  	end
	else
	  # There are no instances of children that have started.  Start some if they should be started.
    if ci.chain.children.any?
      runChildren(ci)
    end  
  end
end

###################################
def isOpen(instance)
  if instance.completedtime.nil?
    return true
  end
  return false
end

###################################
def isTimedOut(instance)
  timeoutseconds = instance.timeout.to_i * 60
  if instance.starttime.to_f + timeoutseconds < Time.now.to_f 
    return true
  else
    return false
  end
end


###################################
def isCronStyleEntry(cronentry)

  puts "cronentry = " + cronentry if DEBUG == 1
  if cronentry =~ /^[0-9,\*]+\s+[0-9,\*]+\s+[0-9,\*]+\s+[0-9,\*]+\s+[0-9,\*]+\s*.*/
    puts "is a cron style entry" if DEBUG == 1
    return true
  else
    puts "Not a cron style entry." if DEBUG == 1
    return false
  end
end

def isSameTime(crontime, currenttime)
 
  if crontime == "*"
    return true
  end
   crontimei = crontime.to_i
   currenttimei = currenttime.to_i
   puts "Passed crontime '" + crontime.to_s + "' and currenttime '" + currenttime.to_s + "'"
   
  if crontimei == currenttimei 
    return true
  end
  puts crontime.to_s + " is not equal to " + currenttime.to_s
  
  puts "checking for commas" if DEBUG==1
  if crontime.include? ","
    puts "found commas " if DEBUG==1
    cronarray = crontime.split(/,/)
    cronarray.each do |time|
 #     puts "comparing " + currenttime.to_s + " to " + time.to_s if DEBUG==1
      if time.to_i == currenttime.to_i 
        puts "Match! " if DEBUG==1
        return true
      end
    end
  end
  return false
end


###################################
def isRightTimeForNew(chain)
  cronentry = chain.precondition
  unless isCronStyleEntry(chain.precondition)
    if chain.precondition == "1"
      # TODO:  CHECK TO SEE IF PAREENT ACTUALLY EXITED SUCCESSFULLY!
      puts "Run it if the previous entry was ok" if DEBUG==1
      return true
    else
      puts "precon = " +  chain.precondition.to_s if DEBUG==1
      puts "Run it if the previous entry was errored" if DEBUG==1
      return false
    end
  end
  
  ta = Time.now.to_a
  ca = cronentry.split(/\s+/)
  # TODO Allow for comma delimited time statements within the Cron entry.
  # The cron current allows for exact hour,minute,second,etc., or * for wildcard.
  
  if RUNEVERYTIME == 1
    puts "returning true for isRightTime" if DEBUG == 1
    return true
  end

  if isSameTime(ca[0], ta[1]) && isSameTime(ca[1], ta[2]) &&  isSameTime(ca[2], ta[3]) && isSameTime(ca[3], ta[4]) && isSameTime(ca[4], ta[6]) 
    puts "Its time to run!" if DEBUG == 1
    return true
  else
    puts "its not time to run" if DEBUG == 1
    return false
  end
  
end


###################################
def parentInstancesDone(pis)
  done=true
  unless pis.nil?
    pis.each do |pi|
      if pi.completedtime.nil?
        done=false
      end
    end
  end
  return done
end

##################################
def alreadyStartedThisOne(c)
  # This checks to see if an isntances has already been started AND CLOSED
  puts "looking for existing instances of this chain that started in this minute." if DEBUG==1
  mySQL = %{ select * from chain_instances where concat(DATE_FORMAT(now(),'%y-%m-%d'), " ", hour(now()), ":", minute(now()) )  = concat(DATE_FORMAT(starttime,'%y-%m-%d'), " ", hour(starttime), ":", minute(starttime))  and chain_id = } + c.id.to_s + ";"
  puts mySQL if DEBUG==1
  return ChainInstance.find_by_sql(mySQL).any?
end

##################################
def createInstance(c)
    puts "creating a new instance" if DEBUG == 1
    ci=c.chain_instances.create
    ci.starttime = Time.now
    ci.timeout = ci.chain.timeout
    ci.save
    rc = runChainInstance(ci,0)
    ci.status = rc
    ci.completedtime = Time.now
    ci.save
    return ci
end


###################################
def getParentInstances(c)
  pis = nil
  c.parents.each do |p|
    p.chain_instances do |ci|
      pis << ci
    end
  end
  return pis
end



###################################
def currentInstanceExists(c)
  # currently assumes that each chain can only run one at a time!
  return c.chain_instances.find_all_by_completed_and_status("0", nil).any?
end


###################################
def CheckAllActions(pool)
  ### THIS IS THE MAIN LOOP
  puts "pool item" if DEBUG == 1
  if pool.actions.any?
    puts "found some actions." if DEBUG == 1
  end
  pool.actions.each do |a|
    puts "Found action: " + a.description if DEBUG == 1
    begin
      a.chains.each do |c|
        puts "Found a chain: " + c.chain_instances.count.to_s if DEBUG == 1

        # Find out if I need to run something that is a child from another
        # server.
        pis = getParentInstances(c)
        if parentInstancesDone(pis)
          unless currentInstanceExists(c)
            unless pis.nil?
              pis.each do |ci|
                puts "handling parent instances from posisbly another host" if DEBUG ==1
                RunAllBottomEntries(ci)
              end
            end
          end
        end

        #all archiving is done from server that top Parent gets called from?
        # This should be run from a master archiver process on the server.
        unless c.parents.any?
          c.chain_instances.find_all_by_completed("0").each do |ci|
            unless openInstancesInTree(ci)
              ArchiveChainInstanceTree(ci)
            end
          end
        end

        # Start any jobs that are waiting for crontime.
        if isRightTimeForNew(c)
          if currentInstanceExists(c)
            # Check all chain instances.
            puts "current instance exists..."
            c.chain_instances.each do |ci|
              puts "found an existing instance: " + ci.id.to_s if DEBUG == 1
              ransomething = RunAllBottomEntries(ci)
              if ransomething == true || ransomething.nil?
                 ArchiveChainInstanceTree(ci) 
              end
            end  # c.chain_instances
          else # if c.chain_instances.any?
            puts " no instnace  exists." if DEBUG ==1
            unless alreadyStartedThisOne(c)
              ci = createInstance(c)
              puts "completed time " + ci.completedtime.to_s
              # This could be a subroutine
              ransomething = RunAllBottomEntries(ci)
              if ransomething == true || ransomething.nil? 
                ArchiveChainInstanceTree(ci)
              end

            else
              puts "A chain has already started this minute." if DEBUG==1
            end
          end # if c.chain_instances.any?
        end

      end # a.chains
    rescue
        puts "Problem parsing all chain actions." + $! if DEBUG == 1
    end
  end
  
end


###################################
###################################
## PRIMARY CODE
###################################
###################################


