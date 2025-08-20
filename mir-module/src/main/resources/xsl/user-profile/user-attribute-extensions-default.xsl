<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:import href="xslImport:userProfileAttributeExtensions:user-profile/user-attribute-extensions-default.xsl"/>

  <xsl:param name="MCR.ORCID.LinkURL"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template match="user" mode="user-important-attributes">
    <xsl:apply-imports />

    <xsl:if test="attributes/attribute[@name='id_orcid']">
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="document('i18n:user.profile.id.orcid')/i18n/text()"/>
          <xsl:text>:</xsl:text>
        </th>
        <td class="col-md-9">
          <xsl:variable name="url" select="concat($MCR.ORCID.LinkURL,attributes/attribute[@name='id_orcid']/@value)"/>
          <a href="{$url}">
            <img alt="ORCID iD" src="{$WebApplicationBaseURL}images/orcid_icon.svg" class="orcid-icon"/>
            <xsl:value-of select="$url"/>
          </a>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
