<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <!-- ========== Repeater buttons: <xed:repeat><xed:controls> ========== -->

  <xsl:template match="text()" mode="xed.control" priority="10">
    <!-- append insert remove up down -->
    <xsl:param name="name" /> <!-- name to submit as request parameter when button/image is clicked -->

    <!-- Choose a label for the button -->
    <xsl:variable name="symbol">
      <xsl:choose>
        <xsl:when test=".='append'">
          <xsl:value-of select="'angle-down'" />
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

    <button type="submit" class="btn btn-default" name="{$name}">
      <i class="fa fa-{$symbol}">
      </i>
    </button>
  </xsl:template>

</xsl:stylesheet>
