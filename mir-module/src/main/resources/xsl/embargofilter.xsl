<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="mcrxsl i18n" xmlns:ex="http://exslt.org/dates-and-times" extension-element-prefixes="ex">
  <xsl:param name="CurrentUser" />
  <xsl:param name="MCR.Users.Guestuser.UserName" />
  <xsl:template match="derobjects">
    <xsl:variable name="embargo" select="../../metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']" />
    <xsl:choose>
      <xsl:when
        test="$CurrentUser=$MCR.Users.Guestuser.UserName and count($embargo) &gt; 0 and mcrxsl:compare(string($embargo),ex:date-time()) &gt; 0">
            <!-- embargo is active for guest user -->
        <xsl:comment>
          <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.accessCondition.embargo.available',$embargo)" />
        </xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>