<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:userProfileAttributes:user-profile/user-profile-attributes-defaults.xsl"/>

  <xsl:template match="user" mode="user-attributes">
    <xsl:apply-imports />

    <xsl:if test="$fullDetails">
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
