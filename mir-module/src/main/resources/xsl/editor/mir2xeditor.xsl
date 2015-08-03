<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mir="http://www.mycore.de/mir"
  exclude-result-prefixes="xsl mir">

  <xsl:include href="copynodes.xsl" />
  
  <xsl:template name="mir-helpbutton">
    <span class="btn btn-default info-button" data-toggle="popover" data-placement="right" data-content="{@help-text}">
      <i class="fa fa-info"></i>
    </span>
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
  
  <xsl:template name="mir-textfield">
    <label class="col-md-3 control-label ">
      <xed:output i18n="{@label}" /> 
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
            <xsl:call-template name="mir-textfield" />
          </div>
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <xsl:call-template name="mir-textfield" />
          </div>
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mir:textfield.repeat">
  <!-- depricated after removing edit mir-textfield-->
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

  <xsl:template match="mir:textarea">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
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
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:role.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][@authority='marcrelator']='{@role}']" min="1" max="100">
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
      </xed:bind>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:person.repeated">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal']" min="1" max="100">
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
          </xed:bind>
        </div>
     </xed:bind>
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
      <div class="form-group">
        <label class="col-md-3 control-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <div class="input-group">
            <input class="form-control relItemsearch" data-searchengine="{@searchengine}" data-genre="{@genre}" 
                  data-responsefield="{@responsefield}" data-provide="typeahead" type="text" autocomplete="off"/>
            <span class="input-group-addon searchbadge"> 
              
            </span>
		  </div>
        </div>
      </div>
    </xed:bind> 
  </xsl:template>

</xsl:stylesheet>
