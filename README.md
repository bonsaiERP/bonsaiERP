# *bonsai*
*bonsai* is a simple ERP system to control the most basic stuff for a company, that includes:

- Sales
- Buys
- Expenses
- Bank accounts
- Inventory

 The software is been improved as we move

## Javascript

In case you want to write javascript it must be inclosed in a
`content_for`

````
    - content_for :scripts do
      :coffeescript
        ( ($) ->
          $('.matchcode').live('focusout', (event) ->
            arr = this.value.trim().split(" ")
            if $('.first_name').val() == ""
              $('.first_name').val(arr[0])
            arr.shift()

            if($('.last_name').val() == "")
              $('.last_name').val( arr.join(" "))
          )
        )(jQuery)
        
