# Changes

Used this [bs migration list](https://getbootstrap.com/docs/5.0/migration/).
Noted changes only, but kept the content structure.


## Dependencies
## Browser support
## Documentation changes

## Sass

- Media query mixins parameters have changed for a more logical approach.

Replaced existing documentation/file structure:

    // Extra large devices (large desktops) and below
    // no (xl) media query necessary (desktop first)
    // set the defaults for all responsive levels here



    // Large devices (desktops) and below
    @include media-breakpoint-down(lg) {
        // add/overwrite styles for responsive level lg and lower
    }

    // Medium devices (tablets) and below
    @include media-breakpoint-down(md) {
        // add/overwrite styles for responsive level md and lower
    }

    // Small devices (landscape phones) and below
    @include media-breakpoint-down(sm) {
        // add/overwrite styles for responsive level sm and lower
    }

    // Extra small devices (portrait phones)
    @include media-breakpoint-down(xs) {
        // add/overwrite styles for responsive level xs
    }

by:

    // set the defaults for all responsive levels here (desktop first)
    // after that, use the media queryies to adujust the lower responsive levels

    // XX-Large devices (larger desktops)
    // No media query since the xxl breakpoint has no upper bound on its width




    // X-Large devices (large desktops, less than 1400px)
    @include media-breakpoint-down(xxl) {
      // add/overwrite styles for responsive level xl and lower
    }

    // Large devices (desktops, less than 1200px)
    @include media-breakpoint-down(xl) {
      // lg and lower
    }

    // Medium devices (tablets, less than 992px)
    @include media-breakpoint-down(lg) {
      // md and lower
    }

    // Small devices (landscape phones, less than 768px)
    @include media-breakpoint-down(md) {
      // sm and lower
    }

    // X-Small devices (portrait phones, less than 576px)
    @include media-breakpoint-down(sm) {
      // xs
    }

Moved media rules to its new include.


## Color system

Replaced lighten() and darken() calls.

    Use tint-color() to replace lighten()
    Use shade-color() to replace darken()

## Grid updates

- Columns no longer have position: relative applied, so you may have to add .position-relative to some elements to restore that behavior.

## Content, Reboot, etc

- Links are underlined by default (not just on hover), unless they’re part of specific components.

Changed default by setting variables in flatmir.

$link-decoration:       none !default;
$link-hover-decoration: underline !default;

Defined link behaviour in a styleguide.
See: https://mycore.atlassian.net/browse/MIR-1504

## RTL

- Horizontal direction specific variables, utilities, and mixins have all been renamed to use logical properties like those found in flexbox layouts—e.g., start and end in lieu of left and right.

## Forms

- Dropped .input-group-append and .input-group-prepend. You can now just add buttons and .input-group-text as direct children of the input groups.
- Dropped form-specific layout classes for our grid system. Use our grid and utilities instead of .form-group, .form-row, or .form-inline.
- Form labels now require .form-label.
- Consolidated native and custom form elements. Checkboxes, radios, selects, and other inputs that had native and custom classes in v4 have been consolidated. Now nearly all our form elements are entirely custom, most without the need for custom HTML.
  - .custom-control.custom-checkbox is now .form-check.
  - .custom-control.custom-radio is now .form-check.
  - .custom-control.custom-switch is now .form-check.form-switch.
  - .custom-select is now .form-select.
  - .custom-file and .form-control-file have been replaced by custom styles on top of .form-control.
  - .custom-range is now .form-range.
  - Dropped native .form-control-file and .form-control-range.

Replaced .custom-control.custom-checkbox by .form-check

Replaced .custom-control-input by .form-check-input

Replaced .custom-control-label by .form-check-label

Replaced .form-group by .mir-form-group

Replaced .custom-select by .form-select

## Components
### Accordion
### Alerts
### Badges

- Dropped all .badge-* color classes for background utilities (e.g., use .bg-primary instead of .badge-primary).
- Dropped .badge-pill—use the .rounded-pill utility instead.
- Removed hover and focus styles for `<a>` and `<button>` elements.

Replaced:
badge- by bg-
badge-pill by rounded-pill

Repairs hover effect for links with badge class, but should be replaced by buttons later.

    a,
    button {
      &.badge {
        &.bg-primary,
        &.text-bg-primary {
          &:hover,
          &:focus {
            background-color: shift-color($primary,$btn-hover-bg-shade-amount) !important;
          }
        }
      }
    }


### Breadcrumbs
### Buttons

- Dropped .btn-block for utilities. Instead of using .btn-block on the .btn, wrap your buttons with .d-grid and a .gap-* utility to space them as needed. Switch to responsive classes for even more control over them. Read the docs for some examples.

### Card
### Carousel
### Close button
### Collapse
### Dropdowns

- Data attributes for all JavaScript plugins are now namespaced to help distinguish Bootstrap functionality from third parties and your own code. For example, we use data-bs-toggle instead of data-toggle.

Replaced data-toggle="dropdown" by data-bs-toggle="dropdown"
Replaced data-toggle="collapse" by data-bs-toggle="collapse"
Replaced data-toggle="tab" by data-bs-toggle="tab"
Replaced data-toggle="tooltip" by data-bs-toggle="tooltip"
Replaced data-toggle="popover" by data-bs-toggle="popover"
Replaced data-toggle="button" by data-bs-toggle="button"
Replaced data-toggle="modal" by data-bs-toggle="modal"

collapse-next ist ein eigener Wert mit eigener Funktion.
Umbenannt nach: data-mcr-toggle

Die Bibliothek (node modules) myclabs enthält noch bs4 code.

### Jumbotron

- Dropped the jumbotron component as it can be replicated with utilities.

Added a container inside of nav.

    <nav class="navbar">
      <div class="container-fluid">
      </div>
    </nav>

### List group
### Navs and tabs
### Navbars

- Navbars now require a container within (to drastically simplify spacing requirements and CSS required).
- The .active class can no longer be applied to .nav-items, it must be applied directly on .nav-links.

Moved active classes from nav-item to nav-link.

### Offcanvas
### Pagination
### Popovers
### Spinners
### Toasts
### Tooltips
## Utilities

- Renamed several utilities to use logical property names instead of directional names with the addition of RTL support
  - Renamed .left-* and .right-* to .start-* and .end-*.
  - Renamed .float-left and .float-right to .float-start and .float-end.
  - Renamed .border-left and .border-right to .border-start and .border-end.
  - Renamed .rounded-left and .rounded-right to .rounded-start and .rounded-end.
  - Renamed .ml-* and .mr-* to .ms-* and .me-*.
  - Renamed .pl-* and .pr-* to .ps-* and .pe-*.
  - Renamed .text-left and .text-right to .text-start and .text-end.

Renamed:
mr- with me-
float-right to float-end
float-left to float-start
text-left to text-start
text-right to text-end
ml to ms
mr to me


## Helpers
## JavaScript

- Data attributes for all JavaScript plugins are now namespaced to help distinguish Bootstrap functionality from third parties and your own code. For example, we use data-bs-toggle instead of data-toggle.


# not found

- button group in forms, like complex_intern.xed
  - a span inside of the button groups prevents correct border renderering
  - seems is located in mycore
- each <select> needs a form-select class, is missing in change password




[MD Syntax](https://www.markdownguide.org/basic-syntax/)
