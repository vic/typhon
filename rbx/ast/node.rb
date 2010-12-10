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

    def self.node(name, *attributes)
      cls = Class.new(Node)
      self.const_set(name, cls)
      Nodes[name.to_s.to_sym] = cls
      attributes = [:line] + attributes
      names = attributes.map { |a| a.to_s.sub(/^_/, '') }
      attrs = names.map { |a| '@' + a }
      args  = attributes.map { |a| a.to_s.sub(/^_/, '*') }

      cls.attr_accessor *names
      cls.module_eval <<-INIT
        def initialize(#{args.join(', ')})
          #{attrs.join(', ')} = #{names.join(', ')}
        end
      INIT
    end

    class Node < Rubinius::AST::Node
    end

    node :Module,    :docstr, :body

    node :Stmt,      :_statements

    node :Printnl,   :expr, :out

    node :Const,     :value

    node :Discard,   :expr

    node :Dict,      :_items

    node :List,      :_items

    node :Tuple,     :_items

  end
end
