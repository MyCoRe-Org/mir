<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:userExtentionsBase:user-actions-base.xsl"/>

  <!-- terminate the import chain for user actions -->
  <xsl:template match="user" mode="actions"/>
  <!-- terminate the import chain for user important attributes -->
  <xsl:template match="user" mode="user-important-attributes"/>
</xsl:stylesheet>
