<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:userProfileAttributes:user-profile/user-profile-attributes-base.xsl"/>

  <xsl:param name="MIR.User.ShowSimpleDetailsOnly"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:variable name="isUserAdmin" select="document('notnull:checkPermission:administrate-users')/boolean = 'true'"/>
  <xsl:variable name="fullDetails" select="$isUserAdmin or not($MIR.User.ShowSimpleDetailsOnly='true')"/>

  <xsl:template match="user" mode="user-attributes"/>

</xsl:stylesheet>
