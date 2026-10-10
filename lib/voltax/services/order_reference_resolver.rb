require_relative "../reference_directory"

module VoltaX
  module Services
    class OrderReferenceResolver
      def initialize(directory:)
        @directory = directory
      end

      def resolve(account:, reference_code:)
        context = reference_context_for(account)
        resolve_from_reference_book(
          reference_book: reference_book_for(context),
          reference_code: reference_code
        )
      end

      private

      attr_reader :directory

      def reference_context_for(account)
        {
          account_id: account.fetch(:id),
          account_profile: account[:account_profile],
          channel: :desk_order
        }
      end

      def reference_book_for(context)
        directory.reference_book_for(context)
      end

      def resolve_from_reference_book(reference_book:, reference_code:)
        reference_book.lookup(reference_code: reference_code)
      end
    end
  end
end
