<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mir="http://www.mycore.de/mir"
  xmlns:xed="http://www.mycore.de/xeditor">
  <xsl:variable name="grid-width" select="12" />
  <xsl:variable name="input-width" select="9" />
  <xsl:variable name="label-width" select="$grid-width - $input-width" />
  <xsl:template match="mir:template[@name='textInput' or @name='selectInput' or @name='submitButton']">
    <div class="form-group">
      <xsl:apply-templates select="." mode="formline" />
    </div>
  </xsl:template>

  <!-- MODE=formline -->

  <xsl:template match="mir:template[@name='textInput' or @name='selectInput']" mode="formline">
    <xsl:apply-templates select="." mode="label" />
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="concat('col-md-',$input-width)" />
      </xsl:attribute>
      <div>
        <xsl:attribute name="class">
          <xsl:if test="@tooltip">
            <xsl:value-of select="'input-group '" />
          </xsl:if>
        </xsl:attribute>
        <xed:bind xpath="{@xpath}">
          <xsl:apply-templates select="." mode="widget" />
          <xsl:apply-templates select="." mode="inputTooltip" />
        </xed:bind>
      </div>
    </div>
  </xsl:template>
  <xsl:template match="mir:template[@name='submitButton']" mode="formline">
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="@target">
          <xsl:value-of select="@target" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'debug'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="col-md-offset-{$label-width} col-md-{$input-width}">
      <button type="submit" xed:target="{$target}" class="btn btn-primary">
        <xed:output i18n="{@i18n}" />
      </button>
    </div>
  </xsl:template>

  <!-- MODE=widget -->

  <xsl:template match="mir:template[@name='textInput']" mode="widget">
    <input type="text" class="form-control" id="{@id}">
      <xsl:attribute name="placeholder">
        <xsl:value-of select="concat('{i18n:',@i18n,'}')" />
      </xsl:attribute>
    </input>
  </xsl:template>
  <xsl:template match="mir:template[@name='selectInput']" mode="widget">
    <select class="form-control" id="inputInst1">
      <option value="">
        <xed:multi-lang>
          <xed:lang xml:lang="de">(bitte wählen)</xed:lang>
          <xed:lang xml:lang="en">(please select)</xed:lang>
        </xed:multi-lang>
      </option>
      <xed:include uri="{@uri}" />
    </select>
  </xsl:template>

  <xsl:template match="mir:template" mode="label">
    <label for="{@id}" class="col-md-{$label-width} control-label">
      <xsl:choose>
        <xsl:when test="@i18n"><xed:output i18n="{@i18n}"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@label" /></xsl:otherwise>
      </xsl:choose>
    </label>
  </xsl:template>
  <xsl:template match="mir:template" mode="inputTooltip">
    <xsl:if test="@tooltip">
      <span class="input-group-addon" data-toggle="tooltip">
        <xsl:attribute name="title">
          <xsl:value-of select="concat('{i18n:',@tooltip,'}')" />
        </xsl:attribute>
        <i class="glyphicon glyphicon-info-sign"></i>
      </span>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>