#!/usr/bin/ruby
require 'config/schema'
require 'socket'
hostname = Socket.gethostname
h=Host.find_by_name(hostname)
h=Host.first

### TO DOS:
# remove action_Type_id
# add actual commands to actions table  command:


# TODO:  validate that parent_chain_id exists in chains, validate that child_chain_id exists in chains;


def ArchiveChainInstance(ci)
  # Archive this to another table.
  puts "NEED TO CREATE ARCHIVING"
  return
end

def runChildren(ci)
  ci.chain.children.each do |child|
    childinstance = ci.child.create
    childinstance.starttime = Time.now
    childinstance.timeout = chain.timeout # TODO:  Add the timeout field to the chains table!!!
    childinstance.save
    puts "Running command: " + ci.chain.action.command
    System(ci.chain.action.command)  # TODO:  Trap the exit status and the output!!!
  end
end


def RunAllBottomEntries(ci)
  puts "Running all bottom entries."
	if isOpen(ci)
		# dont touch this one cause its waiting to complete.
	elsif isTimeOut(ci)
		FindFalseChild(ci)
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
	if instance.timeout + instance.starttime < Time.now
		# Timed out!  
		return true
	end
	return false
end

def isRightTime(chain)
  cronentry = chain.condition
  timearray = Time.new.to_a
  cronarray = cronentry.split(/\s+/)
  # TODO Compare cronarray and timearray.  
  return true
end

def CheckAllActions(pool)
  puts "pool item"
  if pool.actions.any?
    puts "found some actions."
  end
  pool.actions.each do |a|
    puts "Performing action: " + a.description
    begin
      a.chains.each do |c|
        puts "Found a chain: " + c.chain_instances.count.to_s
        if c.active == true  # TODO:  create an active flag for chains
          if isRightTime(c)
            c.chain_instances.each do |ci|
              puts "found an instance."
              ransomething = RunAllBottomEntries(ci)
              if ransomething == true
                ArchiveChainInstance(ci)
              end  # if
            end  # c.chain_instances
          end
        end
      end # a.chains
    rescue
        puts "Problem parsing all chain actions."
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
  puts "Caught some crazy issue!"
end

