<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="xsl xalan i18n">

  <xsl:import href="xslImport:userProfileActionsBase:user-attributes-important-base"/>

  <xsl:param name="MCR.ORCID.LinkURL"/>
  <xsl:param name="WebApplicationBaseURL"/>

  <xsl:template match="user" mode="user-important-attributes">
    <xsl:if test="attributes/attribute[@name='id_orcid']">
      <tr class="d-flex">
        <th class="col-md-3">
          <xsl:value-of select="i18n:translate('user.profile.id.orcid')"/>
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
