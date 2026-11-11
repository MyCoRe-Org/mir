<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:output method="xml" encoding="UTF-8" indent="no"/>

  <xsl:template match="/jats:abstract">
    <html>
      <xsl:apply-templates select="*"/>
    </html>
  </xsl:template>

  <xsl:template match="jats:title[normalize-space(text())='Abstract']">
  </xsl:template>

  <xsl:template match="jats:title">
    <p>
      <strong>
        <xsl:apply-templates/>
      </strong>
    </p>
  </xsl:template>

  <xsl:template match="jats:p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="jats:bold">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="jats:italic">
    <em>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template match="jats:underline">
    <u>
      <xsl:apply-templates/>
    </u>
  </xsl:template>

  <xsl:template match="jats:monospace">
    <code>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <xsl:template match="jats:sub">
    <sub>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>

  <xsl:template match="jats:sup">
    <sup>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>

  <xsl:template match="jats:list-item">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
