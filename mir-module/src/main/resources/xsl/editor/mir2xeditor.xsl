<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mir="http://www.mycore.de/mir"
  exclude-result-prefixes="xsl mir">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mir:textfield">
    <xed:bind xpath="{@xpath}">
      <div>
        <xsl:attribute name="class">form-group {$xed-validation-marker}</xsl:attribute>
        <label class="col-md-3 control-label {@class}">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <input type="text" class="form-control">
            <xsl:copy-of select="@placeholder" />
          </input>
        </div>
      </div>
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:textarea">
    <xed:bind xpath="{@xpath}">
      <div>
        <xsl:attribute name="class">form-group {$xed-validation-marker}</xsl:attribute>
        <label class="col-md-3 control-label {@class}">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <textarea class="form-control">
            <xsl:copy-of select="@rows" />
            <xsl:copy-of select="@placeholder" />
          </textarea>
        </div>
      </div>
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:role.repeated">
    <xed:repeat xpath="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][@authority='marcrelator']='{@role}']" min="1" max="100">
      <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
        <div>
          <xsl:attribute name="class">form-group {$xed-validation-marker}</xsl:attribute>
          <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
            <label class="col-md-3 control-label {@class}">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <div class="controls">
                <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields" />
              </div>
            </div>
            <xsl:call-template name="mir-pmud" />
          </xed:bind>
        </div>
      </xed:bind>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:person.repeated">
    <xed:repeat xpath="mods:name[@type='personal']" min="1" max="100">
      <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
        <div>
          <xsl:attribute name="class">form-group {$xed-validation-marker}</xsl:attribute>
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
            <xsl:call-template name="mir-pmud" />
          </xed:bind>
        </div>
     </xed:bind>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:pmud">
    <xsl:call-template name="mir-pmud" />
  </xsl:template>

  <xsl:template name="mir-pmud">
    <div class="form-pmud">
      <span>
        <xed:controls>insert</xed:controls>
      </span>
      <span>
        <xed:controls>remove</xed:controls>
      </span>
      <span>
        <xed:controls>up</xed:controls>
      </span>
      <span>
        <xed:controls>down</xed:controls>
      </span>
    </div>
  </xsl:template>

</xsl:stylesheet>
