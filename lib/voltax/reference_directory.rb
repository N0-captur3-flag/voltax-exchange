module VoltaX
  class ReferenceDirectory
    class AccountReferenceBook
      def initialize(order_repository:, account_id: nil, scope: :account)
        @order_repository = order_repository
        @account_id = account_id
        @scope = scope
      end

      def lookup(reference_code:)
        return order_repository.resolve_order_reference(reference_code: reference_code) if scope == :desk_book

        order_repository.find_reference_for_account(user_id: account_id, reference_code: reference_code)
      end

      private

      attr_reader :order_repository, :account_id, :scope
    end

    def initialize(order_repository:)
      @order_repository = order_repository
    end

    def find_reference_for_account(account_id:, reference_code:)
      order_repository.find_reference_for_account(user_id: account_id, reference_code: reference_code)
    end

    def reference_book_for(context)
      AccountReferenceBook.new(
        order_repository: order_repository,
        account_id: context.fetch(:account_id),
        scope: reference_scope_for(context)
      )
    end

    def account_order_references(account_id:)
      AccountReferenceBook.new(order_repository: order_repository, account_id: account_id)
    end

    private

    attr_reader :order_repository

    def reference_scope_for(context)
      return :desk_book if context.fetch(:channel) == :desk_order

      :account
    end
  end
end
