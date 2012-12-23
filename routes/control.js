
/*
 * GET the control page.
 */

exports.index = function(req, res){
  res.render('control', { title: 'Control' });
};
