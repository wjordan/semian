require 'forwardable'

module Semian
  module SysV
    class State < Semian::Simple::State #:nodoc:
      include SysVSharedMemory
      extend Forwardable

      def_delegators :@integer, :semid, :shmid, :synchronize, :transaction,
                     :shared?, :acquire_memory_object, :bind_initialize_memory_callback
      private :shared?, :acquire_memory_object, :bind_initialize_memory_callback

      def initialize(name:, permissions:)
        @integer = Semian::SysV::Integer.new(name: name, permissions: permissions)
        initialize_lookup
      end

      def destroy
        super
        @integer.destroy
      end

      def value
        @num_to_sym.fetch(@integer.value) { raise ArgumentError }
      end

      private

      def value=(sym)
        @integer.value = @sym_to_num.fetch(sym) { raise ArgumentError }
      end

      def initialize_lookup
        # Assume symbol_list[0] is mapped to 0
        # Cannot just use #object_id since #object_id for symbols is different in every run
        # For now, implement a C-style enum type backed by integers

        @sym_to_num = {closed: 0, open: 1, half_open: 2}
        @num_to_sym = @sym_to_num.invert
      end
    end
  end
end
