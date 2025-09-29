<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:userProfileAttributes:user-profile/user-profile-attributes-base.xsl"/>

  <xsl:template match="user" mode="user-attributes"/>
  <xsl:template match="user" mode="user-important-attributes"/>
  <xsl:template match="user" mode="user-owner-and-roles"/>
</xsl:stylesheet>
