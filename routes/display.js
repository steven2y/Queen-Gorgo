
/*
 * GET home page.
 */

exports.display = function(req, res){
  res.render('display', { title: 'Display' });
};
