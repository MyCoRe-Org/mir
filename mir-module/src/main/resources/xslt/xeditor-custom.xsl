<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  exclude-result-prefixes="xsl xed mcri18n">

  <xsl:import href="functions/i18n.xsl" />
  
  <!-- ========== Repeater buttons: <xed:repeat><xed:controls> ========== -->

  <xsl:template match="text()" mode="xed.control">
    <!-- append insert remove up down -->
    <xsl:param name="name" /> <!-- name to submit as request parameter when button/image is clicked -->

    <!-- Choose a label for the button -->
    <xsl:variable name="symbol">
      <xsl:choose>
        <xsl:when test=".='append'">
          <xsl:value-of select="'plus'" />
        </xsl:when>
        <xsl:when test=".='insert'">
          <xsl:value-of select="'plus'" />
        </xsl:when>
        <xsl:when test=".='remove'">
          <xsl:value-of select="'minus'" />
        </xsl:when>
        <xsl:when test=".='up'">
          <xsl:value-of select="'arrow-up'" />
        </xsl:when>
        <xsl:when test=".='down'">
          <xsl:value-of select="'arrow-down'" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <button type="submit" class="btn btn-secondary" name="{$name}">
      <i class="fas fa-{$symbol}">
      </i>
    </button>
  </xsl:template>

  <!-- ========== Validation error messages: <xed:validate /> ========== -->

  <xsl:template match="xed:validate[@i18n]" mode="message">
    <li>
      <xsl:choose>
        <xsl:when test="@disable-output-escaping='yes'">
          <xsl:value-of disable-output-escaping="yes" select="mcri18n:translate(@i18n)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcri18n:translate(@i18n)" />
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template match="xed:validate" mode="message">
    <li>
      <xsl:apply-templates select="node()" mode="xeditor" />
    </li>
  </xsl:template>

</xsl:stylesheet>
