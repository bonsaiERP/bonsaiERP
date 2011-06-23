(function() {
  $(function() {
    var Payment;
    return Payment = (function() {
      function Payment() {}
      Payment.prototype.intialize = function(currency_id, accounts, rates) {
        this.currency_id = currency_id;
        this.accounts = accounts;
        this.rates = rates;
        return this.set_account_id_event();
      };
      Payment.prototype.set_account_id_event = function() {
        return $('#payment_account_id').live('change keyup', function() {
          var account_id;
          return account_id = $(this).val() * 1;
        });
      };
      return Payment;
    })();
  });
}).call(this);
