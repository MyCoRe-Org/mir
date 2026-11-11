<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='delete']" mode="object-action">
    <xsl:param name="object" as="element(mycoreobject)" tunnel="yes" />
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="delete" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:variable name="superuser" select="string(mcrproperty:get('MCR.Users.Superuser.UserName'))" />
    <xsl:if test="(not($guest) or $write) and (($superuser != '' and $CurrentUser = $superuser) or $delete)">
      <li class="mir-action-item mir-action-item-delete-object">
        <xsl:choose>
          <xsl:when test="$object/structure/children/child">
            <xsl:attribute name="class" select="'disabled'" />
            <a href="#" title="{mcri18n:translate('object.hasChildren')}" class="dropdown-item">
              <xsl:value-of select="mcri18n:translate('object.delObject')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a href="{$ServletsBaseURL}object/delete?id={$object-id}" class="confirm_deletion dropdown-item" data-text="{mcri18n:translate('mir.confirm.text')}">
              <xsl:value-of select="mcri18n:translate('object.delObject')" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
