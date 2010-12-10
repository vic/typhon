class Typhon
  class AST

    Nodes = Hash.new

    # Converts a ruby sexp (array literals) into Typhon AST
    def self.from_sexp(sexp)
      return nil if sexp.nil? || sexp.empty?
      name = sexp.first
      type = Nodes[name]
      raise "Unknown sexp type: #{name}" unless type
      convert = lambda do |e|
        if e.kind_of?(Array) && e.first.kind_of?(Symbol)
          from_sexp(e)
        elsif e.kind_of?(Array)
          e.map(&convert)
        else
          e
        end
      end
      args = sexp[1..-1].map(&convert)
      type.new(*args)
    end

    def self.node(name, *attributes)
      cls = ::Class.new(Node)
      self.const_set(name, cls)
      Nodes[name.to_s.to_sym] = cls
      names = ['line'] + attributes
      attrs = names.map { |a| '@' + a }

      cls.attr_accessor *names
      cls.module_eval <<-INIT
        def initialize(#{names.join(', ')})
          #{attrs.join(', ')} = #{names.join(', ')}
        end
      INIT
    end

    # Base Node class.
    class Node < Rubinius::AST::Node
    end

    # Nodes classes. Read from node.py
    nodes = eval File.read(File.expand_path("../../bin/node.py", File.dirname(__FILE__)))
    nodes.each { |n| node n.first, *n.last }


  end
end
