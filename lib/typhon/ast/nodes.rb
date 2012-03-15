module Typhon
  module AST

    Nodes = Hash.new

    # Converts a ruby sexp (array literals) into Typhon AST
    def self.from_sexp(sexp)
      return nil if sexp.nil? || sexp.empty?
      name = :"#{sexp.first}Node"
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
      name_sym = :"#{name}Node"
      begin
        cls = self.const_get(name_sym)
      rescue NameError
      end
      cls = cls || ::Class.new(BlowUpNode)

      self.const_set(name_sym, cls)
      Nodes[name_sym] = cls
      names = ['line'] + attributes
      attrs = names.map { |a| '@' + a }

      cls.send :attr_accessor, *names
      cls.module_eval <<-INIT
        def initialize(#{names.join(', ')})
          #{attrs.join(', ')} = #{names.join(', ')}
        end
      INIT
    end

    class Node < Rubinius::AST::Node
    end
    class ClosedScope < Rubinius::AST::ClosedScope
    end

    class BlowUpNode < Node
      def bytecode(g)
        pos(g)
        raise "Unimplemented bytecode for #{self.class}!"
      end
    end

    [
      'variables',
      'control',
      'function',
      'literal',
      'module',
      'utility',
      'class',
      'operators',
    ].each do |type|
      require 'typhon/ast/nodes/' + type
    end

    # Nodes classes. Read from node.py
    nodes = eval File.read(File.expand_path("../../../bin/node.py", File.dirname(__FILE__)))
    nodes.each { |n| node n.first, *n.last }
  end
end
