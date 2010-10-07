#!/usr/bin/ruby
#require 'config/schema'
require 'config/database_configuration.rb'
Dir["../app/models/*.rb"].each {|file| require file }

require 'socket'
DEBUG=1
hostname = Socket.gethostname
h=Host.find_by_name(hostname)
h=Host.first

### TO DOS:
# remove action_Type_id
# add actual commands to actions table  command:


# TODO:  validate that parent_chain_id exists in chains, validate that child_chain_id exists in chains;


def ArchiveChainInstance(ci)
  # Archive this to another table.
  puts "NEED TO CREATE ARCHIVING" if DEBUG
  return
end

def runChainInstance(ci)
  puts "Running command: " + ci.chain.action.command if DEBUG
  rc = system(ci.chain.action.command)  # TODO:  Trap the exit status and the output!!! (WISHLIST)
  if rc
    childinstance.status = true
    childinstance.save
    return true
  else
    childinstance.status = false
    childinstance.save
    return false
  end
end

def runChildren(ci)
  ci.chain.children.each do |child|
    childinstance = ci.child.create
    childinstance.starttime = Time.now
    childinstance.timeout = chain.timeout 
    childinstance.save
    return runChainInstances(ci)
  end
end

def runFalseChild(ci)
  puts "finding false child."
  ci.children.each do |cic|
    puts "checking " if DEBUG
    if cic.chain.precondition == 0 
      return runChainInstance(cic)
    end
  end
end


def RunAllBottomEntries(ci)
  puts "Running all bottom entries." if DEBUG
	if isOpen(ci)
		# dont touch this one cause its waiting to complete.
		puts "It is still running.  Waiting for it to time out or complete."
	elsif isTimedOut(ci)
	  puts "Timed out" if DEBUG
		runFalseChild(ci)
	  ransometime = true
	else
		if ci.children.any?
		  ci.children.each do |child|
		    if child.chain.precondition == ci.status
		      rc = RunAllBottomEntries(child)
	        if ransomething == false and rc == true
	          ransomething = true
          end
	      end
      end
    else
      if ci.chain.children.any?
        runChildren(ci)
        ransomething = true
      end
    end
	end
	return ransomething
end


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

def isOpen(instance)
	unless instance.completed.nil?
		return true
	end
	return false
end

def isTimedOut(instance)
  timeoutseconds = instance.timeout.to_i * 60
  if instance.starttime.to_f + timeoutseconds < Time.now.to_f 
    return true
  else
    return false
  end
end

def isCronStyleEntry(cronentry)

  puts "cronentry = " + cronentry
  if cronentry =~ /^[0-9\*]+\s+[0-9\*]+\s+[0-9\*]+\s+[0-9\*]+\s+[0-9\*]+\s+.*/
    return true
  else
    puts "Not a cron style entry." if DEBUG
    return false
  end
end

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
  if ca[0] == "*" 
    ta[1] = "*"
  end
  if ca[1] == "*"
    ta[2] = "*"
  end
  if ca[2] == "*"
    ta[3] = "*"
  end
  if ca[3] == "*"
    ta[4] = "*"
  end
  if ca[4] == "*"
    ta[6] == "*"
  end
  
  #TEMPORARY TODO
  puts "returning true for isRightTime" if DEBUG
  return true

  if ta[1] == ca[0] && ta[2] == ca[1] && ta[3] == ca[2] && ta[4] == ca[3] && ta[6] == ca[4] 
    puts "Its time to run!"
    return true
  else
    puts "its not time to run"
    return false
  end
  
end

def CheckAllActions(pool)
  puts "pool item"
  if pool.actions.any?
    puts "found some actions."
  end
  pool.actions.each do |a|
    puts "Found action: " + a.description
    begin
      a.chains.each do |c|
        puts "Found a chain: " + c.chain_instances.count.to_s
       # if c.active == true  # TODO:  create an active flag for chains  .. THink about this first... should i be doing it from automations?
          if isRightTime(c)
            puts "look for instances" if DEBUG
            if c.chain_instances.any?
              c.chain_instances.each do |ci|
                puts "found an instance."
                ransomething = RunAllBottomEntries(ci)
                if ransomething == true
                  ArchiveChainInstance(ci)
                end  # if
              end  # c.chain_instances
            else
              #CreateInstance!
              ci=c.chain_instances.create
              ci.starttime = Time.now
              ci.timeout = ci.chain.timeout
              ci.save
              rc = runChainInstance(ci)
              ci.status = rc
              ci.completed = Time.now
            end
          end
      #  end  # c.active
      end # a.chains
    rescue
        puts "Problem parsing all chain actions." + $! if DEBUG
    end
  end
end


begin
  if h.pools.count > 0
    if h.pools.any? 
      h.pools.each do |p|
        CheckAllActions(p)
      end
    end
  end
rescue
  puts "Caught some crazy issue!" + $! if DEBUG
end

