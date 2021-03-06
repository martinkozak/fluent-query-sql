# encoding: utf-8
require "fluent-query/drivers/shared/tokens/sql"
require "hash-utils/object"   # >= 0.17.0

module FluentQuery
    module Drivers
        module Shared
            module Tokens
                module SQL
                                    
                     ##
                     # Generic SQL query HAVING token.
                     #
                     
                     class Having < FluentQuery::Drivers::Shared::Tokens::SQLToken

                        ##
                        # Renders this token.
                        #

                        public
                        def render!(mode = :build)
                            _class = self.unknown_token
                            
                            stack = [ ]
                            unknown = [ ]
                            
                            operator = @_driver.quote_operator(:and)
                            processor = @_query.processor

                            result = "HAVING "

                            # Process subtokens
                            
                            @_subtokens.each do |token|
                                arguments = token.arguments
 
                                # Known process
                                if token.name == :having
                                    length = arguments.length
                                    first = arguments.first
                                    
                                    if length > 0
                                        if (length > 1) or (first.string?)
                                            stack << processor.process_formatted(arguments, mode)
                                        elsif first.array?
                                            stack << first.join(operator)
                                        elsif first.hash?
                                            stack << processor.process_hash(first, operator)
                                        end
                                    end

                                    # Closes opened native token with unknown tokens
                                    if unknown.length > 0
                                        native = _class::new(@_driver, @_query, unknown)
                                        stack << native
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
                                stack << native
                                unknown = [ ]
                            end

                            # Process stack with results
                            first = true
                            
                            stack.each do |item|
                                if item.kind_of? _class
                                    result << item.render!
                                elsif item.string?
                                    if not first
                                        result << operator << " "
                                    else
                                        first = false
                                    end
                                    
                                    result << item
                                end

                                result << " "
                            end

                            return result
                        end
                    end
                end
            end
        end
    end
end
