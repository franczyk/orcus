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
            if runAction
              unless instanceExists(c)
                #create instance
                ci=ChainInstance.create
                ci.chain_id = c.id
                runAction(c.action)
              end
            end
          end
        end
      end
    end
  end
rescue
  puts "Pools issue"
end

def runsNow(precondition)
  return 1
end

def instanceExists(chain)
  # search to see if an instance of this chain exists (for this time)'
  # How do i determine if a particular instance exists?  Base it off of some certain existance?  Time stamp? 
  #  Can place the timestamp of the instance in the instance.  THen, look for the instance next time?
  #   What if it is a child of a parent event?   hm
  
  ci.find_by_chain_id(chain.id) 
  
  
  puts "instanceExists?"
end

def runAction(action)
  puts "Running " + action.command
end