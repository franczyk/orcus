#!/usr/bin/ruby
#require 'config/schema'
require 'config/database_configuration.rb'
Dir["../app/models/*.rb"].each {|file| require file }

require 'socket'
DEBUG=1
RUNEVERYTIME=0
hostname = Socket.gethostname
h=Host.find_by_name(hostname)
if h.nil?
  h = Host.create
  h.name = hostname
  h.save
end

#h=Host.first
puts "Logging last checkin for " + hostname if DEBUG == 1
h.last_checkin = Time.now
h.save



### TODOs:
### validate that parent_chain_id exists in chains, validate that child_chain_id exists in chains;
### Move all this business logic into a web service/ controller.  
# =>  Call it via a basic "controller.xml", and have it return the stuff that needs to run.


### WISHLISTS
### Trap the output of the system() command.
### Allow for mulitple parents, multiple children.  - It appears to already be done!



###################################

def getTopParent(ci)
  parent = ci
  if ci.parents.any?
    ci.parents.each do |p|
      parent=p
      getTopParent(parent)
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
def runChainInstance(ci)
  puts "Running command: " + ci.chain.action.command if DEBUG == 1
  rc = system(ci.chain.action.command)  
  if rc
    ci.status = true
    ci.save
    return true
  else
    ci.status = false
    ci.save
    return false
  end
end

###################################
def runChildren(ci)
  puts "running children: " + ci.id.to_s if DEBUG == 1
  ci.chain.children.each do |child|
    childinstance = child.chain_instances.create
    childinstance.starttime = Time.now
    childinstance.timeout = child.timeout 
    childinstance.save
    return runChainInstance(ci)
  end
end

###################################
def runFalseChild(ci)
  puts "finding false child."
  ci.children.each do |cic|
    puts "checking " if DEBUG == 1
    if cic.chain.precondition == 0 
      return runChainInstance(cic)
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
	unless instance.completedtime.nil?
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
  if cronentry =~ /^[0-9\*]+\s+[0-9\*]+\s+[0-9\*]+\s+[0-9\*]+\s+[0-9\*]+\s*.*/
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
  
  puts "checking for commas"
  if crontime.include? ","
    cronarray = crontime.split(/,/)
    cronarray.each do |time|
      if time == currenttime 
        return true
      end
    end
  end
  return false
end


###################################
def isRightTime(chain)
  cronentry = chain.precondition
  unless isCronStyleEntry(chain.precondition)
    if chain.precondition == 1 
      return true
    else
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
       # if c.active == true  # TODO:  create an active flag for chains  .. THink about this first... should i be doing it from automations?
          if isRightTime(c)
            instances = c.chain_instances.find_all_by_completed("0")
            puts "look for instances" if DEBUG == 1
            if instances.any?
              # Check all chain instances.
              
              c.chain_instances.each do |ci|
                puts "found an existing instance: " + ci.id.to_s if DEBUG == 1
                ransomething = RunAllBottomEntries(ci)
                if ransomething == true || ransomething.nil?
                   ArchiveChainInstanceTree(ci) 
                end  
              end  # c.chain_instances
            
            else # if c.chain_instances.any?
              puts "looking for existing instances of this chain that started in this minute." if DEBUG==1
              mySQL = %{ select * from chain_instances where concat(DATE_FORMAT(now(),'%y-%m-%d'), " ", hour(now()), ":", minute(now()) )  = concat(DATE_FORMAT(starttime,'%y-%m-%d'), " ", hour(starttime), ":", minute(starttime))  and chain_id = } + c.id.to_s + ";" 
              puts mySQL
              instances = ChainInstance.find_by_sql(mySQL)
                #     select * from chain_instances where starttime = concat(DATE_FORMAT(starttime,'%y-%m-%d'), " " ,
                #     hour(starttime),":", minute(starttime)) ;
              unless instances.any?
                createInstance(c)
              else
                puts "A chain has already started this minute." if DEBUG==1
              end
            end # if c.chain_instances.any?
          end
      #  end  # c.active
      end # a.chains
    rescue
        puts "Problem parsing all chain actions." + $! if DEBUG == 1
    end
  end
  
end


def createInstance(c)
    puts "creating a new instance" if DEBUG == 1
    ci=c.chain_instances.create
    ci.starttime = Time.now
    ci.timeout = ci.chain.timeout
    ci.save
    rc = runChainInstance(ci)
    ci.status = rc
    ci.completedtime = Time.now
end


###################################
###################################
## PRIMARY CODE
###################################
###################################

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

