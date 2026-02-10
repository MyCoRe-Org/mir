<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mir="http://www.mycore.de/mir"
  exclude-result-prefixes="xsl mir i18n">


  <xsl:include href="copynodes.xsl" />
  <xsl:variable name="institutesURI">
    <xsl:choose>
      <xsl:when test="string-length(document('classification:metadata:0:children:mir_institutes')/mycoreclass/label[lang('x-uri')]/@text) &gt; 0">
        <xsl:value-of select="document('classification:metadata:0:children:mir_institutes')/mycoreclass/label[lang('x-uri')]/@text" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'http://www.mycore.org/classifications/mir_institutes'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="mir-helpbutton">
    <a
      tabindex="0"
      class="btn btn-secondary info-button"
      role="button"
      data-bs-toggle="popover"
      data-bs-placement="right"
      data-bs-container="body"
      data-bs-trigger="focus"
      data-bs-content="{@help-text}">
      <i class="fas fa-info"></i>
    </a>
  </xsl:template>

  <xsl:template match="mir:textfield.nobind">
    <div class="mir-form-group row">
      <label for="nobind_{@label}" class="col-md-3 col-form-label text-end form-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@divClass}">
        <input id="nobind_{@label}" type="text" class="form-control {@inputClass}" name="">
          <xsl:copy-of select="@placeholder" />
          <xsl:copy-of select="@autocomplete" />
        </input>
      </div>
      <div class="col-md-3">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="mir-helpbutton" />
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir-required">
    <xsl:if test="@required='true'">
      <xed:validate required="true" display="global">
        <xsl:value-of select="i18n:translate(@required-i18n)" />
      </xed:validate>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir-required-relItem">
    <xsl:if test="@required='true'">
      <xed:validate required="true" relevant-if="../../@xlink:href=''" display="global">
        <xsl:value-of select="i18n:translate(@required-i18n)" />
      </xed:validate>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir-textfield">
    <xsl:variable name="textfield_id" select="concat('textfield',@label,'{xed:generate-id()}')" />
    <label for="{$textfield_id}" class="col-md-3 col-form-label text-end form-label">
      <xsl:if test="@label">
        <xed:output i18n="{@label}" />
      </xsl:if>
    </label>
    <div class="col-md-6">
      <input id="{$textfield_id}" type="text" class="form-control">
        <xsl:copy-of select="@placeholder" />
      </input>
    </div>
    <div class="col-md-3">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="mir-helpbutton" />
      </xsl:if>
      <xsl:if test="@repeat = 'true'">
        <xsl:call-template name="mir-pmud" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="mir:textfield">
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="mir-form-group row {@class} {$xed-val-marker}">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
                  <xsl:call-template name="mir-textfield" />
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="mir-textfield" />
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <xsl:call-template name="mir-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="mir-form-group row {@class} {$xed-val-marker}">
            <xsl:call-template name="mir-textfield" />
          </div>
          <xsl:call-template name="mir-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mir:textfield.repeat">
  <!-- deprecated after removing edit mir-textfield-->
    <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
      <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
      <div class="mir-form-group row {@class} {$xed-val-marker}">
        <xsl:call-template name="mir-textfield" />
        <div class="col-md-3 {@class}">
          <xsl:call-template name="mir-pmud" />
        </div>
      </div>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:dateRange">
    <div class="mir-form-group row">
      <label for="{@label}_date" class="col-md-3 col-form-label text-end form-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@class}" data-type="{@type}">
        <xsl:call-template name="mir-dateRange">
          <xsl:with-param name="showDateTimeOption" select="@showDateTimeOption"/>
          <xsl:with-param name="startsWithDateTime" select="@startsWithDateTime"/>
        </xsl:call-template>
      </div>
      <div class="col-md-3">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="mir-helpbutton" />
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="mir:dateRangeInput">
    <div class="{@class}" data-type="{@type}">
      <xsl:call-template name="mir-dateRange">
        <xsl:with-param name="showDateTimeOption" select="@showDateTimeOption"/>
      </xsl:call-template>
    </div>
  </xsl:template>

  <xsl:template name="mir-dateRange">
    <xsl:param name="showDateTimeOption" select="'false'" />
    <xsl:param name="startsWithDateTime" select="'false'" />
    <xsl:variable name="timeClass">
      <xsl:choose>
        <xsl:when test="$startsWithDateTime='true'">
          <xsl:text>startsWithDatetime</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dateRangeWithTime">
      <xsl:choose>
        <xsl:when test="$showDateTimeOption='true'">
          <xsl:text>withTime</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="xpathSimple" >
      <xsl:value-of select="concat(@xpath,'[not(@point)]')"/>
    </xsl:variable>
    <xsl:variable name="xpathStart" >
      <xsl:value-of select="concat(@xpath,'[@point=', $apos, 'start', $apos, ']')"/>
    </xsl:variable>
    <xsl:variable name="xpathEnd" >
      <xsl:value-of select="concat(@xpath,'[@point=', $apos, 'end', $apos, ']')"/>
    </xsl:variable>
    <xsl:variable name="hiddenclasssimple" >
      <xsl:if test="@onlyRange = 'true' ">d-none</xsl:if>
    </xsl:variable>
    <xsl:variable name="hiddenclassrange" >
      <xsl:if test="not(@onlyRange = 'true')">d-none</xsl:if>
    </xsl:variable>
    <div class="date-format" data-format="simple">
      <div class="date-simple {$hiddenclasssimple} input-group mb-1">
        <xed:bind xpath="{$xpathSimple}">
          <input id="{@label}_date" aria-labelledby="_date" type="text" class="form-control {$timeClass}" autocomplete="off">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <xsl:call-template name="date-selectFormat">
          <xsl:with-param name="showDateTimeOption" select="$showDateTimeOption"/>
        </xsl:call-template>
      </div>
      <div class="date-range input-group {$hiddenclassrange} input-daterange">
        <xed:bind xpath="{$xpathStart}">
          <input aria-label="start Date" type="text" class="form-control {$dateRangeWithTime} startDate" data-point="start">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <span class="fas fa-minus input-group-text" aria-hidden="true"></span>
        <xed:bind xpath="{$xpathEnd}">
          <input aria-label="end Date" type="text" class="form-control {$dateRangeWithTime} endDate" data-point="end">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <xsl:if test="not(@onlyRange = 'true') ">
          <xsl:call-template name="date-selectFormat">
            <xsl:with-param name="showDateTimeOption" select="$showDateTimeOption"/>
          </xsl:call-template>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="date-selectFormat">
    <xsl:param name="showDateTimeOption" select="'false'" />
    <div class="date-selectFormat">
      <button class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown"><span class="caret"></span><span class="sr-only">Toggle Dropdown</span></button>
      <ul class="dropdown-menu dropdown-menu-end">
        <li>
          <a href="#" class="date-simpleOption dropdown-item">
            <xsl:value-of select="i18n:translate('mir.date.specification')" />
          </a>
        </li>
        <li>
          <a href="#" class="date-rangeOption dropdown-item">
            <xsl:value-of select="i18n:translate('mir.date.period')" />
          </a>
        </li>
        <xsl:if test="$showDateTimeOption='true'">
        <li>
          <a href="#" class="date-timeOption dropdown-item">
            <xsl:value-of select="i18n:translate('mir.date.datetime')" />
          </a>
        </li>
        </xsl:if>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="mir:htmlArea">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <div class="mir-form-group row {@class} {$xed-val-marker}">
            <xsl:variable name="htmlArea_id" select="concat('htmlArea',@label,generate-id(.))" />
            <label for="{$htmlArea_id}" class="col-md-3 col-form-label text-end form-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <xsl:choose>
                <xsl:when test="@bind" >
                  <xed:bind xpath="{@bind}" >
                    <textarea id="{$htmlArea_id}" class="form-control">
                      <xsl:copy-of select="@rows" />
                      <xsl:copy-of select="@placeholder" />
                    </textarea>
                  </xed:bind>
                </xsl:when>
                <xsl:otherwise>
                  <textarea id="{$htmlArea_id}" class="form-control tinymce">
                    <xsl:copy-of select="@rows" />
                    <xsl:copy-of select="@placeholder" />
                  </textarea>
                </xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="mir-helpbutton" />
              </xsl:if>
              <xsl:call-template name="mir-pmud" />
            </div>
          </div>
          <xsl:call-template name="mir-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="htmlArea_id2" select="concat('htmlArea2',@label,'{xed:generate-id()}')" />
          <div class="mir-form-group row {@class} {$xed-val-marker}">
            <label for="{$htmlArea_id2}" class="col-md-3 col-form-label text-end form-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <textarea id="{$htmlArea_id2}" class="form-control tinymce">
                <xsl:copy-of select="@rows" />
                <xsl:copy-of select="@placeholder" />
              </textarea>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="mir-helpbutton" />
              </xsl:if>
              <xsl:if test="@pmud = 'true'">
                <xsl:call-template name="mir-pmud" />
              </xsl:if>
            </div>
          </div>
          <xsl:call-template name="mir-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mir:textarea">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xsl:variable name="textarea_id2" select="concat('textarea2',@label,'{xed:generate-id()}')" />
          <div class="mir-form-group row {@class} {$xed-val-marker}">
            <label for="{$textarea_id2}" class="col-md-3 col-form-label text-end form-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
                  <textarea id="{$textarea_id2}" class="form-control">
                    <xsl:copy-of select="@rows" />
                    <xsl:copy-of select="@placeholder" />
                  </textarea>
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <textarea id="{$textarea_id2}" class="form-control">
                  <xsl:copy-of select="@rows" />
                  <xsl:copy-of select="@placeholder" />
                </textarea>
              </xsl:otherwise>
            </xsl:choose>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="mir-helpbutton" />
              </xsl:if>
              <xsl:call-template name="mir-pmud" />
            </div>
          </div>
          <xsl:call-template name="mir-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="textarea_id3" select="'{xed:generate-id()}'" />
          <div class="mir-form-group row {@class} {$xed-val-marker}">
            <label for="{$textarea_id3}" class="col-md-3 col-form-label text-end form-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <textarea id="{$textarea_id3}" class="form-control">
                <xsl:copy-of select="@rows" />
                <xsl:copy-of select="@placeholder" />
              </textarea>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="mir-helpbutton" />
              </xsl:if>
              <xsl:if test="@pmud = 'true'">
                <xsl:call-template name="mir-pmud" />
              </xsl:if>
            </div>
          </div>
          <xsl:call-template name="mir-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mir:role.extended.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal' or not(@type) or (@type='corporate' and not(@authorityURI='{$institutesURI}'))][mods:role/mods:roleTerm[@type='code'][@authority='marcrelator']='{@role}']" min="1" max="100">
      <xed:bind xpath="@type" initially="personal"/>
      <fieldset class="personExtended_box">
        <legend class="mir-fieldset-legend hiddenDetail d-flex justify-content-between align-items-center">
        <xed:output i18n="{@label}" />
        <span class="fas fa-chevron-down expand-item" title="{i18n:translate('mir.help.expand')}" data-target=".personExtended-container" role="button" tabindex="0" style="cursor: pointer;" aria-hidden="true"></span>
        </legend>
          <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
            <div class="mir-form-group row {@class} {$xed-val-marker}">
              <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
                <label for="author_search" class="col-md-3 col-form-label text-end form-label">
                  <xed:output i18n="{@label}" />
                </label>
                <div class="col-md-6 center-vertical">
                  <div class="controls">
                    <xed:include ref="person.fields.noHidden" />
                  </div>
                  <span class="fas fa-chevron-down expand-item" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
                </div>
                <div class="col-md-3">
                  <xsl:if test="string-length(@help-text) &gt; 0">
                    <xsl:call-template name="mir-helpbutton" />
                  </xsl:if>
                  <xsl:call-template name="mir-pmud" />
                </div>
              </xed:bind>
              <xsl:call-template name="mir-required" />
            </div>
          </xed:bind>
        <div class="mir-fieldset-content personExtended-container d-none">
          <xed:include ref="nameType" />
          <xed:include ref="namePart.repeated" />
          <xed:include ref="person.affiliation" />
        </div>
      </fieldset>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:role.repeated">
    <xsl:variable name="xed-val-marker">
      {$xed-validation-marker}
    </xsl:variable>
    <xed:repeat
      xpath="mods:name[@type='personal' or not(@type) or (@type='corporate' and not(@authorityURI='{$institutesURI}'))][mods:role/mods:roleTerm[@type='code'][@authority='marcrelator']='{@role}']"
      min="1" max="100">
      <xed:bind xpath="@type" initially="personal" />
      <xed:bind xpath="@simpleEditor" default="true" />
      <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
        <div class="mir-form-group row {@class} {$xed-val-marker}">
          <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
            <label for="personLabel-1-1-" class="col-md-3 col-form-label text-end form-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <div class="controls">
                <xed:include ref="person.fields" />
              </div>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="mir-helpbutton" />
              </xsl:if>
              <xsl:call-template name="mir-pmud" />
            </div>
          </xed:bind>
        </div>
        <xsl:call-template name="mir-required" />
      </xed:bind>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:person.extended.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal'  or not(@type) or (@type='corporate' and not(@authorityURI='{$institutesURI}'))]" min="1" max="100">
      <xed:bind xpath="@type" initially="personal"/>
      <fieldset class="personExtended_box">
        <legend class="mir-fieldset-legend hiddenDetail d-flex justify-content-between align-items-center">
          <span>Autor:in **TODO i18n for legend</span>
        </legend>
          <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
            <div class="mir-form-group row {@class} {$xed-val-marker}">
              <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
                <div class="col-md-3" style="text-align:right; font-weight:bold;">
                  <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" initially="aut">
                    <select aria-label="Select role" class="form-control form-control-inline roleSelect form-select">
                      <xsl:apply-templates select="*" />
                    </select>
                  </xed:bind>
                </div>
                <div class="col-md-6 center-vertical">
                  <xed:include ref="person.fields.noHidden" />
                  <span class="fas fa-chevron-down expand-item" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
                </div>
                <div class="col-md-3">
                  <xsl:if test="string-length(@help-text) &gt; 0">
                    <xsl:call-template name="mir-helpbutton" />
                  </xsl:if>
                  <xsl:call-template name="mir-pmud" />
                </div>
                <xsl:call-template name="mir-required" />
              </xed:bind>
            </div>
         </xed:bind>        
        <div class="mir-fieldset-content personExtended-container d-none">
          <xed:include ref="nameType" />
          <xed:include ref="namePart.repeated" />
          <xed:include ref="person.affiliation" />
          <xsl:if test="@authorSpecification">
            <xed:include ref="authorSpecification.repeated" />
          </xsl:if>
        </div>
      </fieldset>
    </xed:repeat>
    <script>
    function handleRoleSelect(select) {
      const currentRole = select.find(":selected").val();
      const authorSpecificationDivs = select.parents(".personExtended_box").children(".personExtended-container").children(".authorSpecification");
      if (currentRole === "aut") {
        authorSpecificationDivs.show();
      } else {
        authorSpecificationDivs.hide();
      }
    }
    $(document).ready(function() {
      $(".roleSelect").each(function(e) {
        handleRoleSelect($(this));
      });
    });
    $(".roleSelect").change(function(e) {
      handleRoleSelect($(e.currentTarget));
    });
    </script>
  </xsl:template>

  <xsl:template match="mir:person.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal' or not(@type) or (@type='corporate' and not(@authorityURI='{$institutesURI}'))]" min="1" max="100">
      <xed:bind xpath="@type" initially="personal"/>
      <xed:bind xpath="@simpleEditor" default="true"/>
      <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
        <div class="mir-form-group row {@class} {$xed-val-marker}">
          <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
            <div class="col-md-3" style="text-align:right; font-weight:bold;">
              <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" initially="aut">
                <select  aria-label="select role **TODO**" class="form-control form-control-inline form-select">
                  <xsl:apply-templates select="*" />
                </select>
              </xed:bind>
            </div>
            <div class="col-md-6">
              <xed:include ref="person.fields" />
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="mir-helpbutton" />
              </xsl:if>
              <xsl:call-template name="mir-pmud" />
            </div>
            <xsl:call-template name="mir-required" />
          </xed:bind>
        </div>
     </xed:bind>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:insitut.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='corporate'][@authorityURI='{$institutesURI}']" min="{@min}" max="{@max}">
      <xed:bind xpath=".">
      <xed:bind xpath="@valueURIxEditor"/>
      <xsl:variable name="select_id" select="concat(@label,'{xed:generate-id()}')" />
      <div class="mir-form-group row {@class} {$xed-val-marker}">
        <label for="{$select_id}" class="col-md-3 col-form-label text-end form-label">
          <xed:output i18n="{@label}" />
          :
        </label>
        <div class="col-md-6">
          <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" initially="his" /><!--  Host institution [his] -->
            <select id="{$select_id}" class="form-control form-control-inline mir-form__js-select--large form-select">
              <option value="">
                <xed:output i18n="mir.select.optional" />
              </option>
              <xed:include uri="xslStyle:items2options#xslt:classification:editor:-1:children:mir_institutes" />
            </select>
        </div>
        <div class="col-md-3">
          <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="mir-helpbutton" />
          </xsl:if>
          <xsl:call-template name="mir-pmud" />
        </div>
      </div>
    </xed:bind>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:geographic.repeated">
    <xed:repeat xpath="{@path}" min="{@min}" max="{@max}">
        <xed:bind xpath="@authorityURI" initially="http://d-nb.info/gnd/">
          <input type="hidden" />
        </xed:bind>
        <div class="mir-form-group row {@class}">
          <label for="geographic_input" class="col-md-3 col-form-label text-end form-label"><!--**TODO check where this label is used-->
            <xed:output i18n="{@label}" />
          </label>
          <xsl:choose>
            <xsl:when test="@extended='true'">
              <div class="col-md-6 center-vertical">
                <div class="search-geographic-extended">
                  <xed:include ref="geographic.input" />
                </div>
                <span class="fas fa-chevron-down expand-item" data-target=".geographicExtended-container" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="col-md-6">
                <xed:include ref="geographic.input" />
              </div>
            </xsl:otherwise>
          </xsl:choose>
          <div class="col-md-3">
            <xsl:if test="string-length(@help-text) &gt; 0">
              <xsl:call-template name="mir-helpbutton" />
            </xsl:if>
            <xsl:call-template name="mir-pmud" />
          </div>
        </div>
        <span class="geographicExtended-container d-none">
          <xed:include ref="geographicIdentifier" />
        </span>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:topic.repeated">
    <xed:repeat xpath="mods:topic" min="{@min}" max="{@max}">
      <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
        <xed:bind xpath="@authorityURI" initially="http://d-nb.info/gnd/">
          <input type="hidden" />
        </xed:bind>
        <div class="mir-form-group row {@class} {$xed-val-marker}">
          <label for="topic_input" class="col-md-3 col-form-label text-end form-label">
            <xed:output i18n="{@label}" />
          </label>
          <xsl:choose>
            <xsl:when test="@extended='true'">
              <div class="col-md-6 center-vertical">
                <div class="search-topic-extended">
                  <xed:include ref="topic.input" />
                </div>
                <span class="fas fa-chevron-down expand-item" data-target=".topicExtended-container" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="col-md-6">
                  <xed:include ref="topic.input" />
                </div>
            </xsl:otherwise>
          </xsl:choose>
          <div class="col-md-3">
            <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="mir-helpbutton" />
            </xsl:if>
            <xsl:call-template name="mir-pmud" />
          </div>
        </div>
        <span class="mir-fieldset-content topicExtended-container d-none">
          <xed:include ref="topicIdentifier" />
        </span>
        <xsl:call-template name="mir-required" />
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:pmud">
    <div class="col-md-3 {@class}">
      <xsl:call-template name="mir-pmud" />
    </div>
  </xsl:template>

  <xsl:template match="mir:help-pmud">
    <div class="col-md-3 {@class}">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="mir-helpbutton" />
      </xsl:if>
      <xsl:if test="@pmud='true'">
        <xsl:call-template name="mir-pmud" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="mir-pmud">
    <span class="pmud-button">
      <xed:controls>insert</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>remove</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>up</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>down</xed:controls>
    </span>
  </xsl:template>

  <xsl:template match="mir:relItemsearch">
    <xed:bind xpath="{@xpath}">
      <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
      <div class="mir-form-group row {@class} {$xed-val-marker}">
        <label for="relItemsearch_{@label}" class="col-md-3 col-form-label text-end form-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <div class="input-group">
            <input id="relItemsearch_{@label}" class="form-control relItemsearch" data-searchengine="{@searchengine}" data-genre="{@genre}"
                   data-valuexpath="//mods:mods/{@xpath}" data-provide="typeahead" type="text" autocomplete="off"
                   placeholder="{@placeholder}" />
            <span class="input-group-addon searchbadge"> </span>
          </div>
        </div>
        <div class="col-md-3">
          <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="mir-helpbutton" />
          </xsl:if>
          <xsl:if test="@pmud = 'true'">
            <xsl:call-template name="mir-pmud" />
          </xsl:if>
        </div>
        <xsl:call-template name="mir-required-relItem" />
      </div>
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:itemsearch">
    <xed:bind xpath="{@xpath}">
      <div class="mir-form-group row">
        <label for="itemsearch_{@label}" class="col-md-3 col-form-label text-end form-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <input id="itemsearch_{@label}" class="form-control itemsearch" data-searchengine="{@searchengine}" data-genre="{@genre}"
                 data-provide="typeahead" type="text" autocomplete="off"
                 placeholder="{@placeholder}"/>
        </div>
        <div class="col-md-3">
          <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="mir-helpbutton" />
          </xsl:if>
          <xsl:if test="@pmud = 'true'">
            <xsl:call-template name="mir-pmud" />
          </xsl:if>
        </div>
      </div>
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:editorConfig">
    <xsl:variable name="editorProperties" select="document('property:MIR.WebConfig.Editor.*')"/>
    <xsl:if test="$editorProperties">
      <xsl:element name="script">
        <xsl:for-each select="$editorProperties/properties/entry">
          <xsl:text>window["</xsl:text>
          <xsl:value-of select="@key"/>
          <xsl:text>"] = </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>;</xsl:text>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
