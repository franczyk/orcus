
class CommandsController < ApplicationController
    DEBUG=0
    RUNEVERYTIME=1

  def show
    hostname = params[:id]
    h = Host.find_by_name(hostname)

    logger.debug params[:id]

    if h.nil?
      logger.debug "h is nil!"
      h = Host.create
      h.name = hostname
      h.save
    end
    h.last_checkin = Time.now
    h.save
  logger.debug "DOING STUFF"
    @action=""
    if h.pools.any?
      logger.debug "some stuff"
    else
      logger.debug "not any for " + hostname
    end

    h.pools.each do |pool| 
      logger.debug "checking actions.\n"
      @action =  CheckAllActions(pool) + "\n"
      if @action == "" 
        break
      end
    end

    # TODO:  Return commands in an object that can be passed to render :xml.

    @host = h
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @host }
    end
  end

end

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
  logger.debug "archiving : " + ci.id.to_s 
  ci.completed = true
  ci.save
  
  children.each do |child|
    ArchiveChainInstanceTree(ci)
  end
  return
end

###################################
def runChainInstance(ci, retrynumber)
  logger.info "Running command: " + ci.chain.action.command 
  return ci.chain.action.command
end


###################################
def runChildren(ci)
  logger.debug "looking for children: " + ci.id.to_s 
  ci.chain.children.each do |child|
    if child.action.pool.hosts.find_by_name(hostname)
      childinstance = child.chain_instances.create
      childinstance.starttime = Time.now
      childinstance.timeout = child.timeout
      childinstance.save
      return runChainInstance(ci,0)
    end
  end
end

###################################
def runFalseChild(ci)
  logger.debug "finding false child."
  ci.children.each do |cic|
    logger.debug "checking " 
    if cic.chain.precondition == 0 
      return runChainInstance(cic,0)
    end
  end
end


###################################
def RunAllBottomEntries(ci)
  logger.debug "Running all bottom entries." 
  if isOpen(ci)
    # dont touch this one cause its waiting to complete.
    logger.debug "It is still running.  Waiting for it to time out or complete: " + ci.chain.action.command 
  elsif isTimedOut(ci)
    logger.debug "Timed out: " + ci.id.to_s 
    ci.completedtime = Time.now
    ci.status = 0
    ci.save
    itemToRun = runFalseChild(ci)
    ransomething = true
  else
    logger.debug "Not timed out, not open.  Closed: " + ci.id.to_s 
    if ci.children.any?
      logger.debug "There are children: " + ci.id.to_s 
      ci.children.each do |child|
        if child.chain.precondition == ci.status
          itemToRun = RunAllBottomEntries(child)
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

  logger.debug "ransomething is set to... '" + ransomething.to_s + "'" 
  return itemToRun
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

  logger.debug "cronentry = " + cronentry 
  if cronentry =~ /^[0-9,\*]+\s+[0-9,\*]+\s+[0-9,\*]+\s+[0-9,\*]+\s+[0-9,\*]+\s*.*/
    logger.debug "is a cron style entry" 
    return true
  else
    logger.debug "Not a cron style entry." 
    return false
  end
end

def isSameTime(crontime, currenttime)
 
  if crontime == "*"
    return true
  end
   crontimei = crontime.to_i
   currenttimei = currenttime.to_i
   logger.debug "Passed crontime '" + crontime.to_s + "' and currenttime '" + currenttime.to_s + "'"
   
  if crontimei == currenttimei 
    return true
  end
  logger.debug crontime.to_s + " is not equal to " + currenttime.to_s
  
  logger.debug "checking for commas" 
  if crontime.include? ","
    logger.debug "found commas " 
    cronarray = crontime.split(/,/)
    cronarray.each do |time|
 #     logger.debug "comparing " + currenttime.to_s + " to " + time.to_s 
      if time.to_i == currenttime.to_i 
        logger.debug "Match! " 
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
      logger.debug "Run it if the previous entry was ok" 
      return true
    else
      logger.debug "precon = " +  chain.precondition.to_s 
      logger.debug "Run it if the previous entry was errored" 
      return false
    end
  end
  
  ta = Time.now.to_a
  ca = cronentry.split(/\s+/)
  # TODO Allow for comma delimited time statements within the Cron entry.
  # The cron current allows for exact hour,minute,second,etc., or * for wildcard.
  
  if RUNEVERYTIME == 1
    logger.debug "returning true for isRightTime" 
    return true
  end

  if isSameTime(ca[0], ta[1]) && isSameTime(ca[1], ta[2]) &&  isSameTime(ca[2], ta[3]) && isSameTime(ca[3], ta[4]) && isSameTime(ca[4], ta[6]) 
    logger.debug "Its time to run!" 
    return true
  else
    logger.debug "its not time to run" 
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
  logger.debug "looking for existing instances of this chain that started in this minute." 
  mySQL = %{ select * from chain_instances where concat(DATE_FORMAT(utc_timestamp(),'%y-%m-%d'), " ", hour(utc_timestamp()), ":", minute(utc_timestamp()) )  = concat(DATE_FORMAT(starttime,'%y-%m-%d'), " ", hour(starttime), ":", minute(starttime))  and chain_id = } + c.id.to_s + ";"
  logger.debug mySQL 
  return ChainInstance.find_by_sql(mySQL).any?
end

##################################
def createInstance(c)
    logger.debug "creating a new instance" 
    ci=c.chain_instances.create
    ci.starttime = Time.now
    ci.timeout = ci.chain.timeout
    ci.save
    return runChainInstance(ci,0)
    #ci.status = rc
    #ci.completedtime = Time.now
    #ci.save
    #return ci
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
  logger.debug "checking chain " 
  value = c.chain_instances.find_all_by_completed_and_status("0", nil).any?
  logger.debug "got value"
  return value
end


###################################
def CheckAllActions(pool)
  itemToRun = ""
  ### THIS IS THE MAIN LOOP
  logger.debug "pool item" 
  if pool.actions.any?
    logger.debug "found some actions." 
  end
  pool.actions.each do |a|
    logger.debug "Found action: " + a.description 
    begin
      a.chains.each do |c|
        logger.debug "Found a chain: " + c.chain_instances.count.to_s 

        # Find out if I need to run something that is a child from another
        # server.
        logger.debug "getting parent instances"
        pis = getParentInstances(c)
        logger.debug "checking parent instances"
        if parentInstancesDone(pis)
          logger.debug "Does current instance exist?"
          unless currentInstanceExists(c)
            logger.debug "current instance exists"
            unless pis.nil?
              pis.each do |ci|
                logger.debug "handling parent instances from posisbly another host"
                itemToRun = RunAllBottomEntries(ci)
              end
            end
          end
        end

        #all archiving is done from server that top Parent gets called from?
        # This should be run from a master archiver process on the server.
        logger.debug "any parents?"
        unless c.parents.any?
          logger.debug "getting all completed"
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
            logger.debug "current instance exists..."
            c.chain_instances.each do |ci|
              logger.debug "found an existing instance: " + ci.id.to_s 
              itemToRun = RunAllBottomEntries(ci)
            end  # c.chain_instances
          else # if c.chain_instances.any?
            logger.debug " no instnace  exists."
            unless alreadyStartedThisOne(c)
              itemToRun = createInstance(c)
              # This could be a subroutine
              #if ransomething == true || ransomething.nil? 
                #ArchiveChainInstanceTree(ci)
              #end

            else
              logger.debug "A chain has already started this minute." 
            end
          end # if c.chain_instances.any?
        end

      end # a.chains
    rescue
        logger.debug "Problem parsing all chain actions." 
    end
  end
  return itemToRun
end


