# Knife attr rm
# Removes attributes from nodes using a search
# Philip Hutchins [ Fri Jun 14 15:27:03 EDT 2013 ]

require 'chef'
require 'chef/knife'

class Chef
  class Knife
    class AttrRm < Chef::Knife

      deps do
        require 'chef/search/query'
        require 'chef/knife/search'
        require 'chef/node'
      end

      banner 'knife attr rm -s KNIFE_SEARCH -a ATTR'

      option :dry_run,
        :short => "-d",
        :long => "--dryrun",
        :boolean => true,
        :default => false,
        :description => "Do not make any changes but show what will be done"

      option :attr,
        :short => '-a ATTR',
        :long => '--attr ATTR',
        :description => 'root level attribute you would like to remove'

      option :knife_search,
        :short => '-s \"KNIFE SEARCH\"',
        :long => '--search \'KNIFE SEARCH\'',
        :description => 'Search to use to find nodes on which to update specified cookbook.'

      def run
        unless @attr = config[:attr]
          ui.error 'You need to specify an attribute to remove'
          exit 1
        end

        unless @knife_search = config[:knife_search]
          ui.error 'You need to specify a knife search'
          exit 1
        end

        dry_run = config[:dry_run]
        if dry_run 
          ui.msg "DRY RUN!"
        end

        query_nodes = Chef::Search::Query.new
        query_nodes.search('node', @knife_search) do |node_item|
          if node_item.has_key?(@attr)
            ui.msg "#{node_item.name}: - Removing: node[#{node_item[@attr].inspect}]"
          else
            ui.msg "#{node_item.name}: - Key not found"
          end
          unless dry_run
            node_item.delete(@attr)
            node_item.save
          end
        end
      end
    end
  end
end
