/*
 * jDropDown
 * http://do-web.com/jdropdown/overview
 *
 * Copyright 2011, Miriam Zusin
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://do-web.com/jdropdown/license
 */
(function($){
   $.fn.jDropDown = function(options){
	   
	var options = $.extend({
		selected: 0,
		callback: ""
	},options);

	return this.each(function() {            
		var hndl = this;
		
		$(this).addClass("jDropDown");
		this.ul = $(this).find("ul");
		this.li_list = this.ul.find("li");
		this.div = $(this).find("div");
		this.par = $(this).find("p");
		
		//init
    //this.par.html(this.ul.find("li:eq(" + options.selected + ")").html());
		
		this.close = function(){
			hndl.ul.hide();
		};
				
		//click
		this.div.click(function(e){
			e.stopPropagation();
			if(hndl.ul.is(":visible")){
				hndl.close();
			}
			else{
				hndl.ul.show();				
			}
		});
		
		this.li_list.click(function(){
		
			var index = $(this).index();
			var val = $(this).html();
      var id = $(this).attr("id")
			
			hndl.par.html(val);
			hndl.close();
			
			if($.isFunction(options.callback)){				
				options.callback(id, val);
			}	
		});
		
		$(document).click(function(){
			hndl.close();
		});
		
	});    
   };
})(jQuery);
