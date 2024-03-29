// Generated by CoffeeScript 1.4.0
(function() {
  var chatView;

  chatView = Backbone.View.extend({
    el: $("#chat"),
    className: ".chatWindow",
    initialize: function() {
      return this;
    },
    template: _.template($("script#chat").html()),
    events: {
      "event1": "method"
    },
    method: function() {},
    render: function() {
      return this.$el.html(this.template(this.model.toJSON()));
    }
  });

}).call(this);
