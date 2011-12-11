# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction
  # Stores changes and check validatioins according to the state
  class Edit
    attr_reader :old_transaction, :transaction, :history

    def initialize(transaction)
      @transaction = transaction
      @old_transaction = ::Transaction.find(@transaction.id) if @transaction.persisted?
    end

    def save
      res = true
      update
      return false if transaction.errors.any?
      return false if changed_unallowed_changes?

      transaction.class.transaction do
        res = @current_ledger.save if @current_ledger
        res = @account.save && res if @account
        res = transaction.save
        raise ActiveRecord::Rollback unless res
      end

      res
    end

    private

    def changed_unallowed_changes?
      if not(transaction.draft?)
        [:contact_id, :ref_number, :currency_id, :exchange_rate].each do |met|
          unless transaction.send(met) === old_transaction.send(met)
            transaction.reload
            transaction.errors[:base] << I18n.t("errors.messages.transaction.changes")
            return true
          end
        end

        false
      end
    end

    def refund_operation
      transaction.is_a?(Income) ? "in" : "out"
    end

    def create_history
      history = transaction.transaction_histories.build
      history.data = old_transaction.attributes.symbolize_keys
      history.data[:taxis_ids] = old_transaction.taxis_ids
      history.user_id = old_transaction.modified_by
      history.data[:transaction_details] = old_transaction.transaction_details.map {|v| v.attributes.symbolize_keys }
    end

    # Updates the state of a transaction based on the balance
    def update_state
      case 
      when transaction.balance > 0
        transaction.state = 'approved'
        transaction.deliver = false #if transaction.deliver.blank?
      when transaction.balance === 0
        transaction.state = 'paid'
        transaction.deliver = true if transaction.account_ledgers.pendent.empty?
      end
    end

    def update
      # Calculate totals and set balance
      transaction.total          = calculate_total
      transaction.balance        = calculate_balance
      transaction.original_total = calculate_orinal_total
      #create replica
      return unless transaction.persisted?

      create_history

      unless transaction.draft? 
        if transaction.account_ledgers.pendent.any?
          transaction.errors[:base] << I18n.t("errors.messages.transaction.unconcilied_ledgers")
          return false
        end

        if old_transaction.total_paid > transaction.total
          pay_type = I18n.t("transaction.#{transaction.class}.paid")
          transaction.errors[:base] << I18n.t("errors.messages.transaction.paid_amount", :pay_type => pay_type)
          return false
        end

        update_state
      end

    end

    def refund
      @account = transaction.contact_account_cur(transaction.currency_id) || build_contact_account
      amount  = old_transaction.total_paid - transaction.balance
      klass   = transaction.class.to_s.downcase

      @account.amount = @account.amount - amount

      @current_ledger = @account.account_ledgers.build(
        :account_id => @account.id,
        :amount => amount,
        :exchange_rate => 1,
        :transaction_id => transaction.id,
        :reference => I18n.t("transaction.#{klass}.refund", :transaction => transaction),
        :operation => refund_operation
      ) {|al| 
        al.conciliation = true
        al.currency_id = @account.currency_id
      }

    end

    def calculate_orinal_total
      s = transaction.transaction_details.inject(0) do |s, det|
        unless det.marked_for_destruction?
          s += ( det.original_price.to_f/transaction.exchange_rate ).round(2) * det.quantity
        end
        s
      end

      t_taxes = transaction.tax_percent/100 * s
      s += t_taxes
      transaction.discounted = (s == transaction.total ? false : true)

      transaction.original_total = s
    end

    # Calculates the real total value and stores it
    def calculate_total
      transaction.tax_percent = transaction.taxes.inject(0) {|s, imp| s += imp.rate }
      transaction.gross_total = transaction.transaction_details.inject(0) {|s,det| s += det.total unless det.marked_for_destruction?; s}
      transaction.total = transaction.gross_total - transaction.total_discount + transaction.total_taxes
    end

    def calculate_balance
      if transaction.draft?
        transaction.total
      else
        balance = old_transaction.balance - (old_transaction.total - transaction.total)
        balance = 0 if balance < 0
        transaction.balance = balance
      end
    end

  end
end
