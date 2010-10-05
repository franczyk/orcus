#!/usr/bin/ruby
require 'config/schema'
require 'socket'
hostname = Socket.gethostname
h=Host.find_by_name(hostname)
h=Host.first

### TO DOS:
# remove action_Type_id
# add actual commands to actions table  command:

begin
  if h.pools.count > 0
    puts "Found some pools."
    if h.pools.any? 
      h.pools.each do |p|
        puts "pool item"
        if p.actions.any?
          puts "found some actions."
        end
        p.actions.each do |a|
          puts a.description
          a.chains.each do |c|
            c.chain_instances.each do |ci|
		          ransomething = RunAllBottomEntries(ci)
		          if ransomething
		            ArchiveChainInstance(c)
	            end
	          end
          end
        end
      end
    end
  end
rescue
  puts "Caught some crazy issue!"
end

def runChildren(ci)
  ci.chain.children.each do |child|
    childinstance = ci.child.create
    childinstance.starttime = Time.now
    childinstance.timeout = chain.timeout # TODO:  Add the timeout field to the chains table!!!
    childinstance.save
    System(ci.chain.action.command)  # TODO:  Trap the exit status and the output!!!
  end
end


def RunAllBottomEntries(ci)
	if isOpen(ci)
		# dont touch this one cause its waiting to complete.
	elsif isTimeOut(ci)
		FindFalseChild(ci)
	else
	 	returnvalue = GetReturnValue(ci)
		if returnValue == true
			RunAllBottomEntries(FindChild(ci, true))
		else
			RunAllBottomEntries(FindChild(ci, false))
		end
	end
end

def FindChild(ci, success)
  if ci.children.any? 
  	ci.children.each do |child|
  		if child.chain.precondition == success 
  			return child  # I need to return multiple children, because multiple children can run on true/false.
  		end
  	end
	else
	  # If there are no children in the instance table, create them if they should exist, and run the job.
	  ### RIGHT HERE.
    if ci.chain.children.any?
      # Need to create them.
      runChildren(ci)
      
    else
      # this was the end of the road.  How do I close this out so that I dont have to scan it in the future?
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




