# encoding: utf-8
require "fluent-query/drivers/shared/tokens/sql"
require "hash-utils/object"   # >= 0.17.0

module FluentQuery
    module Drivers
        module Shared
            module Tokens
                module SQL
                                    
                     ##
                     # Generic SQL query GROUP BY token.
                     #
                     
                     class GroupBy < FluentQuery::Drivers::Shared::Tokens::SQLToken

                        ##
                        # Renders this token.
                        #

                        public
                        def render!(mode = :build)
                            stack = [ ]
                            unknown = [ ]
                            fields = [ ]
                            aliases = { }
                            distinct = false
                            
                            result = "GROUP BY "
                            processor = @_query.processor
                            
                            _class = self.unknown_token

                            # Process subtokens
                            
                            @_subtokens.each do |token|
                                arguments = token.arguments
                                name = token.name

                                # Known select process
                                if name == :groupBy
                                    length = arguments.length
                                    
                                    if length > 0
                                        first = arguments.first
                                        
                                        if first.symbol?
                                            stack << arguments
                                        elsif first.string?
                                            stack << processor.process_formatted(arguments, mode)
                                        else
                                            arguments.each do |argument|
                                                if argument.array?
                                                    fields += argument
                                                end                        
                                            end
                                        end
                                    end

                                    # Closes opened native token with unknown tokens
                                    if unknown.length > 0
                                        native = _class::new(@_driver, @_query, unknown)
                                        stack << native.render!
                                        unknown = [ ]
                                    end

                                # Unknowns arguments pushes to the general native token
                                else
                                    unknown << token
                                end
                            end

                            # Closes opened native token with unknown tokens
                            if unknown.length > 0
                                native = _class::new(@_driver, @_query, unknown)
                                stack << native.render!
                                unknown = [ ]
                            end

                            # Process stack with results
                            
                            first = true
                                                        
                            if not fields.empty?
                                stack.unshift(fields.uniq)
                            end
                            
                            stack.each do |item|
                                
                                if item.array?
                                    if not first
                                        result << ", "
                                    end
                                    
                                    result << processor.process_identifiers(item) 
                                    first = false
                                    
                                elsif item.string?                            
                                    if not first
                                        result << ", "
                                    end
        
                                    result << item.strip!
                                    first = false
                                    
                                end
                            end

                            return result
                        end
                    end
                end
            end
        end
    end
end

