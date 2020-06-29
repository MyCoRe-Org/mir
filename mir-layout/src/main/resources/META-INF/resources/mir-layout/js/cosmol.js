$( document ).ready(function() {

  // load side nav settings from session
  setSideNav();

  // if side nav hidden/shown
  adjustColumns();
  adjustMenuButton();

  // on change windows size
  $( window ).resize(function() {
    // if side nav hidden/shown
    adjustColumns();
    adjustMenuButton();
  });

  // side nav toggle button
  $('.mir-navbar-toggle').click(function(){
    toggleSideNav();
  });
});

/* ****************************************************************************
 * load side nav settings from "session"
 *************************************************************************** */
function setSideNav() {
  if ( typeof(Storage) !== "undefined" ) {
    switch ( localStorage.getItem("sideNav") ) {
      case 'opened':
        if ( !$('#side_nav_column').is(":visible") ) {
          toggleSideNav(0);
        }
        break;
      case 'closed':
        if ( $('#side_nav_column').is(":visible") ) {
          toggleSideNav(0);
        }
        break;
      case null:
        if ( $('#side_nav_column').is(":visible") ) {
          localStorage.setItem("sideNav", "opened");
        } else {
          localStorage.setItem("sideNav", "opened");
        }
        break;
      default:
    }
  }
}

/* ****************************************************************************
 * adjust main content columns
 * depending from visibility of side nav
 **************************************************************************** */
function adjustColumns() {

// define elements
var mainCol  = $('#main_content_column');                  // parent
var leftCol  = $('#main_content_column #main_col');        // left child
var rightCol = $('#main_content_column #aux_col');         // right child
var headline = $('#head_col #headline');                   // title
var browsing = $('#mir-search_browsing > div');            // browse through the hits

// scale or enlarge elements
  if ( $('#side_nav_column').is(":visible") ) {
    // side nav is visible, make one column
    mainCol.removeClass('col-sm-12').addClass('col-sm-9');   // parent
    leftCol.removeClass('col-sm-8').addClass('col-12');   // left
    rightCol.removeClass('col-sm-4').addClass('col-12');  // right
    headline.removeClass('col-md-8').addClass('col-12');  // title
    browsing.removeClass('col-md-8').addClass('col-12');  // browse through the hits
  } else {
    // side nav is hidden, make two columns
    mainCol.removeClass( 'col-sm-9').addClass( 'col-sm-12'); // parent
    leftCol.removeClass( 'col-12').addClass('col-sm-8');  // left
    rightCol.removeClass('col-12').addClass('col-sm-4');  // right
    headline.removeClass('col-12').addClass('col-md-8');  // title
    browsing.removeClass('col-12').addClass('col-md-8');  // browse through the hits
  }
}

/* ****************************************************************************
 * adjust toggle button for site menu
 * depending from visibility of side nav
 * not only controlled by js, but also by css
 **************************************************************************** */
function adjustMenuButton() {
    if ( $('#side_nav_column').is(":visible") ) {
      // site nav is visible now
      // change icon from right to left / down to up on mobile view
      $('.mir-navbar-toggle .mir-menu-icon').removeClass('fa-bars');
      if ( $( document ).width() <= 750 ) {
        $('.mir-navbar-toggle .mir-menu-icon').addClass('fa-chevron-up');
      } else {
        $('.mir-navbar-toggle .mir-menu-icon').addClass('fa-chevron-left');
      }
    } else {
      // site nav is hidden now
      // change icon from left to right / up to down on mobile view
      $('.mir-navbar-toggle .mir-menu-icon').removeClass('fa-chevron-left');
      $('.mir-navbar-toggle .mir-menu-icon').removeClass('fa-chevron-up');
      $('.mir-navbar-toggle .mir-menu-icon').addClass('fa-bars');
    }
}

/* ****************************************************************************
 * toggle side nav
 **************************************************************************** */
function toggleSideNav(speed) {
  if( speed === undefined ) {
    speed = 'slow';
  }
  if ( $('#side_nav_column').is(":visible") ) {
    // site nav is visible
    // hide menu
    $('#side_nav_column').hide(speed, function() {
      adjustColumns();
      adjustMenuButton();
    });
    if ( typeof(Storage) !== "undefined" ) {
      localStorage.setItem("sideNav", "closed");
    }
  } else {
    // site nav is hidden
    // make it visible
    $('#side_nav_column').show('slow');
    $('#side_nav_column').removeClass('d-xs-none');
    $('#side_nav_column').addClass('col-12');
    adjustColumns();
    adjustMenuButton();
    if ( typeof(Storage) !== "undefined" ) {
      localStorage.setItem("sideNav", "opened");
    }
  }
}