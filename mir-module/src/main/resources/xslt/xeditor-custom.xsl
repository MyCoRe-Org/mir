<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n xed xsl">

  <xsl:import href="functions/i18n.xsl" />
  
  <!-- ========== Repeater buttons: <xed:repeat><xed:controls> ========== -->

  <xsl:template match="text()" mode="xed.control">
    <!-- append insert remove up down -->
    <xsl:param name="name" /> <!-- name to submit as request parameter when button/image is clicked -->

    <!-- Ermittelt das dynamische Label: 'button.otherwise' wenn kein Treffer vorliegt -->
    <xsl:variable name="isValid" select="index-of(('append', 'insert', 'remove', 'up', 'down'), .)" />
    <xsl:variable name="buttonLabel" select="if ($isValid) then concat('button.', .) else 'button.otherwise'" />

    <!-- Ermittelt das Icon-Symbol -->
    <xsl:variable name="symbol" select="
      if (.='append' or .='insert') then 'plus' 
      else if (.='remove') then 'minus' 
      else if (.='up') then 'arrow-up' 
      else if (.='down') then 'arrow-down' 
      else ''" />

    <button type="submit" class="btn btn-secondary" name="{$name}" aria-label="{mcri18n:translate($buttonLabel)}">
      <xsl:if test="$symbol != ''">
        <i class="fas fa-{$symbol}"></i>
      </xsl:if>
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
