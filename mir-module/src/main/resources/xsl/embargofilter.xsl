<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exslt="http://exslt.org/common"
  xmlns:dt="http://exslt.org/dates-and-times"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mcracl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exslt mcracl mcri18n mcrxml xlink"
  extension-element-prefixes="dt">

  <xsl:param name="CurrentUser" />
  <xsl:param name="MCR.Users.Guestuser.UserName" />
  <xsl:template match="derobjects">
    <xsl:variable name="embargo" select="../../metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']" />
    <xsl:variable name="nodes">
      <xsl:for-each select="derobject">
        <xsl:if test="mcracl:checkDerivateDisplayPermission(@xlink:href) or not(mcrxml:isCurrentUserGuestUser())">
          <xsl:choose>
            <xsl:when
              test="$CurrentUser=$MCR.Users.Guestuser.UserName and count($embargo) &gt; 0 and mcrxml:compare(string($embargo),dt:date-time()) &gt; 0">
                  <!-- embargo is active for guest user -->
              <xsl:comment>
                <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.accessCondition.embargo.available',$embargo)" />
              </xsl:comment>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy>
                <xsl:apply-templates select="@*|node()" />
              </xsl:copy>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(exslt:node-set($nodes)/derobject) &gt; 0">
        <derobjects class="{@class}">
          <xsl:copy-of select="$nodes" />
        </derobjects>  
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$nodes" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
