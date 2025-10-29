<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="resource:xsl/user-profile/user-profile-attribute-utils.xsl"/>
  <xsl:import href="xslImport:userProfileAttributes:user-profile/user-profile-attributes-defaults.xsl"/>

  <xsl:template match="user" mode="user-attributes">
    <xsl:apply-imports/>

    <xsl:if test="$fullDetails">
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.userAccount')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <xsl:apply-templates select="." mode="name"/>
        </td>
      </tr>

      <xsl:if test="$fullDetails or string-length(password/@hint) &gt; 0">
        <tr class="d-flex">
          <th class="col-md-3">
            <xsl:value-of select="document('i18n:component.user2.admin.passwordHint')/i18n/text()"/>
          </th>
          <td class="col-md-9">
            <xsl:value-of select="password/@hint"/>
          </td>
        </tr>
      </xsl:if>

      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.user.lastLogin')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <xsl:call-template name="formatISODate">
            <xsl:with-param name="date" select="lastLogin"/>
            <xsl:with-param name="format" select="document('i18n:component.user2.metaData.dateTime')/i18n/text()"/>
          </xsl:call-template>
        </td>
      </tr>

      <xsl:if test="$fullDetails or string-length(validUntil) &gt; 0">
        <tr class="d-flex">
          <th class="col-md-3">
            <xsl:value-of select="document('i18n:component.user2.admin.user.validUntil')/i18n/text()"/>
          </th>
          <td class="col-md-9">
            <xsl:call-template name="formatISODate">
              <xsl:with-param name="date" select="validUntil"/>
              <xsl:with-param name="format" select="document('i18n:component.user2.metaData.dateTime')/i18n/text()"/>
            </xsl:call-template>
          </td>
        </tr>
      </xsl:if>
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.user.name')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <xsl:value-of select="realName"/>
        </td>
      </tr>
      <xsl:if test="eMail">
        <tr class="d-flex">
          <th class="col-md-3">
            <xsl:value-of select="document('i18n:component.user2.admin.user.email')/i18n/text()"/>
          </th>
          <td class="col-md-9">
            <a href="mailto:{eMail}">
              <xsl:value-of select="eMail"/>
            </a>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="$fullDetails">
        <tr class="d-flex">
          <th class="col-md-3">
            <xsl:value-of select="document('i18n:component.user2.admin.user.locked')/i18n/text()"/>
          </th>
          <td class="col-md-9">
            <xsl:choose>
              <xsl:when test="@locked='true'">
                <xsl:value-of select="document('i18n:component.user2.admin.user.locked.true')/i18n/text()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="document('i18n:component.user2.admin.user.locked.false')/i18n/text()"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>

      <xsl:if test="$fullDetails">
        <tr class="d-flex">
          <th class="col-md-3">
            <xsl:value-of select="concat(document('i18n:component.user2.admin.user.disabled')/i18n/text(), ':')"/>
          </th>
          <td class="col-md-9">
            <xsl:choose>
              <xsl:when test="@disabled='true'">
                <xsl:value-of select="document('i18n:component.user2.admin.user.disabled.true')/i18n/text()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="document('i18n:component.user2.admin.user.disabled.false')/i18n/text()"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>

      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:component.user2.admin.user.attributes')/i18n/text()"/>
        </th>
        <td class="col-md-9">
          <dl>
            <!-- filter orcid attributes -->
            <xsl:for-each select="attributes/attribute[not(@name='id_orcid' or starts-with(@name, 'orcid_credential_') or  starts-with(@name, 'orcid_user_properties_'))]">
              <dt>
                <xsl:value-of select="@name" />
              </dt>
              <dd>
                <xsl:value-of select="@value" />
              </dd>
            </xsl:for-each>
          </dl>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
