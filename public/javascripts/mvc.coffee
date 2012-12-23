chatView = Backbone.View.extend(
	el: $("#chat")
	className: ".chatWindow"
	initialize: ->
		@
	template: _.template($("script#chat").html())
	events:
		"event1": "method"
	method: ->
		#do something
	render: ->
		@$el.html @template(@model.toJSON())
)