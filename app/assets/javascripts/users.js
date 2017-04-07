/*# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/*/

$( document ).ready(function() {
	$("#profile").click(function() {
		$("#posts").removeClass("selected");
		$("#trips").removeClass("selected");
		$(this).addClass("selected");
	});
	$("#posts").click(function() {
		$("#profile").removeClass("selected");
		$("#trips").removeClass("selected");
		$(this).addClass("selected");
	});

	$("#trips").click(function() {
		$("#posts").removeClass("selected");
		$("#profile").removeClass("selected");
		$(this).addClass("selected");
	});
});