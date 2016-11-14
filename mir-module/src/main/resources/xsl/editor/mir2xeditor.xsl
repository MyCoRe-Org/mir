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
    <a tabindex="0" class="btn btn-default info-button" role="button" data-toggle="popover" data-placement="right" data-content="{@help-text}">
      <i class="fa fa-info"></i>
    </a>
  </xsl:template>

  <xsl:template match="mir:textfield.nobind">
    <div class="form-group">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@divClass}">
        <input id="{@id}" type="text" class="form-control {@inputClass}" name="">
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

  <xsl:template name="mir-textfield">
    <label class="col-md-3 control-label ">
      <xsl:if test="@label">
        <xed:output i18n="{@label}" />
      </xsl:if>
    </label>
    <div class="col-md-6">
      <input id="{@id}" type="text" class="form-control">
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
          <div class="form-group {@class} {$xed-val-marker}">
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
          <div class="form-group {@class} {$xed-val-marker}">
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
      <div class="form-group {@class} {$xed-val-marker}">
        <xsl:call-template name="mir-textfield" />
        <div class="col-md-3 {@class}">
          <xsl:call-template name="mir-pmud" />
        </div>
      </div>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:dateRange">
    <div class="form-group">
      <label class="col-md-3 control-label ">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@class}" data-type="{@type}">
        <xsl:call-template name="mir-dateRange"/>
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
      <xsl:call-template name="mir-dateRange"/>
    </div>
  </xsl:template>

  <xsl:template name="mir-dateRange">
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
      <xsl:if test="@onlyRange = 'true' ">hidden</xsl:if>
    </xsl:variable>
    <xsl:variable name="hiddenclassrange" >
      <xsl:if test="not(@onlyRange = 'true')">hidden</xsl:if>
    </xsl:variable>
    <div class="date-format" data-format="simple">
      <div class="date-simple {$hiddenclasssimple} input-group">
        <xed:bind xpath="{$xpathSimple}">
          <input type="text" class="form-control" autocomplete="off">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <xsl:call-template name="date-selectFormat"/>
      </div>
      <div class="date-range input-group {$hiddenclassrange} input-daterange">
        <xed:bind xpath="{$xpathStart}">
          <input type="text" class="form-control startDate" data-point="start">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <span class="glyphicon glyphicon-minus input-group-addon" aria-hidden="true"></span>
        <xed:bind xpath="{$xpathEnd}">
          <input type="text" class="form-control endDate" data-point="end">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <xsl:if test="not(@onlyRange = 'true') ">
          <xsl:call-template name="date-selectFormat"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="date-selectFormat">
    <div class="input-group-btn date-selectFormat">
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="caret"></span><span class="sr-only">Toggle Dropdown</span></button>
      <ul class="dropdown-menu dropdown-menu-right" role="menu">
        <li>
          <a href="#" class="date-simpleOption">
            <xsl:value-of select="i18n:translate('mir.date.specification')" />
          </a>
        </li>
        <li>
          <a href="#" class="date-rangeOption">
            <xsl:value-of select="i18n:translate('mir.date.period')" />
          </a>
        </li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="mir:textarea">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <div class="form-group {@class} {$xed-val-marker}">
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
                  <textarea class="form-control">
                    <xsl:copy-of select="@rows" />
                    <xsl:copy-of select="@placeholder" />
                  </textarea>
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <textarea class="form-control">
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
          <div class="form-group {@class} {$xed-val-marker}">
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <textarea class="form-control">
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
        <legend class="mir-fieldset-legend hiddenDetail">
          <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
            <div class="form-group {@class} {$xed-val-marker}">
              <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
                <label class="col-md-3 control-label">
                  <xed:output i18n="{@label}" />
                </label>
                <div class="col-md-6 center-vertical">
                  <div class="controls">
                    <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields.noHidden" />
                  </div>
                  <span class="glyphicon glyphicon-chevron-down expand-item" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
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
        </legend>
        <div class="mir-fieldset-content personExtended-container hidden">
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="nameType" />
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="namePart.repeated" />
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.affiliation" />
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="nameIdentifier.repeated" />
        </div>
      </fieldset>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:role.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal' or not(@type) or (@type='corporate' and not(@authorityURI='{$institutesURI}'))][mods:role/mods:roleTerm[@type='code'][@authority='marcrelator']='{@role}']" min="1" max="100">
      <xed:bind xpath="@type" initially="personal"/>
      <xed:bind xpath="@simpleEditor" default="true"/>
      <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
        <div class="form-group {@class} {$xed-val-marker}">
          <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <div class="controls">
                <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields" />
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
        <legend class="mir-fieldset-legend hiddenDetail">
          <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
            <div class="form-group {@class} {$xed-val-marker}">
              <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
                <div class="col-md-3" style="text-align:right; font-weight:bold;">
                  <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" initially="aut">
                    <select class="form-control form-control-inline">
                      <xsl:apply-templates select="*" />
                    </select>
                  </xed:bind>
                </div>
                <div class="col-md-6 center-vertical">
                  <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields.noHidden" />
                  <span class="glyphicon glyphicon-chevron-down expand-item" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
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
        </legend>
        <div class="mir-fieldset-content personExtended-container hidden">
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="nameType" />
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="namePart.repeated" />
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.affiliation" />
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="nameIdentifier.repeated" />
        </div>
      </fieldset>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:person.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal' or not(@type) or (@type='corporate' and not(@authorityURI='{$institutesURI}'))]" min="1" max="100">
      <xed:bind xpath="@type" initially="personal"/>
      <xed:bind xpath="@simpleEditor" default="true"/>
      <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
        <div class="form-group {@class} {$xed-val-marker}">
          <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
            <div class="col-md-3" style="text-align:right; font-weight:bold;">
              <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" initially="aut">
                <select class="form-control form-control-inline">
                  <xsl:apply-templates select="*" />
                </select>
              </xed:bind>
            </div>
            <div class="col-md-6">
              <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields" />
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

  <xsl:template match="mir:topic.repeated">
    <xed:repeat xpath="mods:topic[@authorityURI='http://d-nb.info/gnd/']" min="{@min}" max="{@max}">
        <div class="form-group {@class}">
          <label class="col-md-3 control-label">
            <xed:output i18n="{@label}" />
          </label>
          <xsl:choose>
            <xsl:when test="@extended='true'">
              <div class="col-md-6 center-vertical">
                <div class="search-topic-extended">
                  <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="topic.input" />
                </div>
                <span class="glyphicon glyphicon-chevron-down expand-item" data-target=".topicExtended-container" title="{i18n:translate('mir.help.expand')}" aria-hidden="true"></span>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="col-md-6">
                  <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="topic.input" />
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
        <span class="mir-fieldset-content topicExtended-container hidden">
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="topicIdentifier" />
        </span>
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
      <div class="form-group {@class} {$xed-val-marker}">
        <label class="col-md-3 control-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <div class="input-group">
            <input class="form-control relItemsearch" data-searchengine="{@searchengine}" data-genre="{@genre}"
                   data-valuexpath="//mods:mods/{@xpath}" data-provide="typeahead" type="text" autocomplete="off"/>
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
        <xsl:call-template name="mir-required" />
      </div>
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:itemsearch">
    <xed:bind xpath="{@xpath}">
      <div class="form-group">
        <label class="col-md-3 control-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <input class="form-control itemsearch" data-searchengine="{@searchengine}" data-genre="{@genre}"
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

</xsl:stylesheet>
