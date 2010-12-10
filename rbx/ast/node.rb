class Typhon
  class AST

    Nodes = Hash.new

    # Converts a ruby sexp (array literals) into Typhon AST
    def self.from_sexp(sexp)
      return nil if sexp.nil? || sexp.empty?
      name = sexp.first
      rest = sexp[1..-1]
      type = Nodes[name]
      raise "Unknown sexp type: #{name}" unless type
      body = rest.map { |e| if e.kind_of?(Array) then from_sexp(e) else e end }
      ast = type.new(*body)
      ast
    end

    class Node < Rubinius::AST::Node
      def self.node(name, *attributes)
        Nodes[name.to_s.to_sym] = self
        unless attributes.empty?
          names = attributes.map { |a| a.to_s.sub(/^_/, '') }
          attrs = names.map { |a| '@' + a }
          args  = attributes.map { |a| a.to_s.sub(/^_/, '*') }

          attr_accessor *names

          module_eval <<-INIT
          def initialize(#{args.join(', ')})
            #{attrs.join(', ')} = #{names.join(', ')}
          end
          INIT
        end
      end
    end

    class Module < Node
      node :Module, :line, :docstr, :body
    end

    class Stmt < Node
      node :Stmt, :line, :_statements
    end

    class Printnl < Node
      node :Printnl, :line, :expr, :out
    end

    class Const < Node
      node :Const, :line, :value
    end

    class Discard < Node
      node :Discard, :line, :expr
    end

    class Dict < Node
      node :Dict, :line, :_items
    end

    class List < Node
      node :List, :line, :_items
    end

    class Tuple < Node
      node :Tuple, :line, :_items
    end

  end
end
