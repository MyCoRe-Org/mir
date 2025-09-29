<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:userProfileAttributes:user-profile/user-profile-owners-and-roles.xsl"/>

  <xsl:param name="MCR.ORCID.LinkURL"/>
  <xsl:param name="MIR.User.ShowSimpleDetailsOnly"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template match="user" mode="user-owner-and-roles">
    <xsl:apply-imports/>

    <xsl:variable name="isUserAdmin" select="document('notnull:checkPermission:checkPermission:administrate-users')"/>
    <xsl:variable name="fullDetails" select="$isUserAdmin or not($MIR.User.ShowSimpleDetailsOnly='true')"/>

    <xsl:if test="$fullDetails">
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.owner')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <xsl:apply-templates select="owner" mode="link"/>
          <xsl:if test="count(owner)=0">
            <xsl:value-of select="document('i18n:component.user2.admin.userIndependent')/i18n/text()"/>
          </xsl:if>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="$fullDetails">
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.roles')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <xsl:for-each select="roles/role">
            <xsl:value-of select="@name"/>
            <xsl:variable name="lang">
              <xsl:call-template name="selectPresentLang">
                <xsl:with-param name="nodes" select="label"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat(' [',label[lang($lang)]/@text,']')"/>
            <xsl:if test="position() != last()">
              <br/>
            </xsl:if>
          </xsl:for-each>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="$fullDetails">
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.userOwns')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <xsl:for-each select="$owns/user">
            <xsl:apply-templates select="." mode="link"/>
            <xsl:if test="position() != last()">
              <br/>
            </xsl:if>
          </xsl:for-each>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
