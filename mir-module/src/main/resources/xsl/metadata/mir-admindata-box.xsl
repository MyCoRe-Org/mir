<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:encoder="xalan://xalan://java.net.URLEncoder"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcracl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="encoder i18n mcracl mods xlink mcrxsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-admindata-box.xsl"/>
  <xsl:param name="WebApplicationBaseURL"/>
  <xsl:param name="MIR.Metadata.Admindata.ShowRealUserName"/>
  <xsl:template match="/">
    <xsl:variable name="ID" select="/mycoreobject/@ID"/>
    <div id="mir-admindata">
      <div id="system_box" class="detailbox">
        <h4 id="system_switch" class="block_switch">
          <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.systembox')"/>
        </h4>
        <div id="system_content" class="block_content">
          <table class="metaData">
            <!--*** publication status ************************************* -->
            <tr>
              <td class="metaname">
                <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.status'),':')"/>
              </td>
              <td class="metavalue">
                <xsl:call-template name="printClass">
                  <xsl:with-param select="mycoreobject/service/servstates/servstate" name="nodes"/>
                </xsl:call-template>
              </td>
            </tr>
            <xsl:call-template name="printMetaDate">
              <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='createdate']" name="nodes"/>
              <xsl:with-param select="i18n:translate('metaData.createdAt')" name="label"/>
            </xsl:call-template>

            <xsl:call-template name="print-user-info">
              <xsl:with-param name="user" select="document(concat('notnull:user:', mycoreobject/service/servflags/servflag[@type='createdby']))"/>
              <xsl:with-param name="label" select="i18n:translate('mir.metaData.detailBox.by')"/>
            </xsl:call-template>
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:note">
              <xsl:variable name="noteType">
                <xsl:choose>
                  <xsl:when test="@type">
                    <xsl:value-of select="@type"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'admin'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="myURI"
                            select="concat('classification:metadata:0:children:noteTypes:', mcrxsl:regexp($noteType,' ', '_'))"/>
              <xsl:variable name="x-access">
                <xsl:value-of select="document($myURI)//label[@xml:lang='x-access']/@text"/>
              </xsl:variable>
              <xsl:variable name="noteLabel">
                <xsl:value-of select="document($myURI)//category/label[@xml:lang=$CurrentLang]/@text"/>
              </xsl:variable>
              <xsl:if test="contains($x-access, 'editor') or contains($x-access, 'admin')">
                <xsl:call-template name="printMetaDate">
                  <xsl:with-param select="." name="nodes"/>
                  <xsl:with-param select="$noteLabel" name="label"/>
                </xsl:call-template>
              </xsl:if>
            </xsl:for-each>
            <!--*** Last Modified ************************************* -->
            <xsl:call-template name="printMetaDate">
              <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='modifydate']" name="nodes"/>
              <xsl:with-param select="i18n:translate('metaData.lastChanged')" name="label"/>
            </xsl:call-template>
            <xsl:call-template name="print-user-info">
              <xsl:with-param name="user" select="document(concat('notnull:user:', mycoreobject/service/servflags/servflag[@type='modifiedby']))"/>
              <xsl:with-param name="label" select="i18n:translate('mir.metaData.detailBox.by')"/>
            </xsl:call-template>
            <!--*** MyCoRe-ID and intern ID *************************** -->
            <tr>
              <td class="metaname">
                <xsl:value-of select="concat(i18n:translate('metaData.ID'),':')"/>
              </td>
              <td class="metavalue">
                <xsl:value-of select="mycoreobject/@ID"/>
              </td>
            </tr>
            <xsl:call-template name="printMetaDate">
              <xsl:with-param
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='intern']"
                name="nodes"/>
              <xsl:with-param select="i18n:translate('component.mods.metaData.dictionary.identifier.intern')"
                              name="label"/>
            </xsl:call-template>

            <tr>
              <td class="metaname">
                <xsl:value-of select="i18n:translate('metadata.versionInfo.version')"/>
                <xsl:text>:</xsl:text>
              </td>
              <td class="metavalue">
                <xsl:variable name="verinfo" select="document(concat('notnull:staticcontent:mir-history:', mycoreobject/@ID))"/>
                <xsl:variable name="revision">
                  <xsl:call-template name="UrlGetParam">
                    <xsl:with-param name="url" select="$RequestURL"/>
                    <xsl:with-param name="par" select="'r'"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="not($revision = '')">
                    <xsl:for-each select="$verinfo/versions/version">
                      <xsl:sort order="descending" select="position()" data-type="number"/>
                      <xsl:if test="$revision = @r">
                        <xsl:number/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="count($verinfo/versions/version)">
                        <xsl:value-of select="count($verinfo/versions/version)"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="i18n:translate('metadata.versionInfo.inProgress')"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
                <br/>
                <a id="historyStarter" style="cursor: pointer">
                  <xsl:value-of select="i18n:translate('metadata.versionInfo.startLabel')"/>
                </a>
              </td>
            </tr>
          </table>
        </div>
      </div>

    </div>
    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template name="print-user-info">
    <xsl:param name="user"/>
    <xsl:param name="label"/>

    <xsl:variable name="display-name">
      <xsl:choose>
        <xsl:when test="string-length($user/user/realName) &gt; 0 and $MIR.Metadata.Admindata.ShowRealUserName='true'">
          <xsl:value-of select="$user/user/realName"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$user/user/@name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="userid-with-realm" select="concat($user/user/@name, '@', $user/user/@realm)"/>

    <tr>
      <td class="metaname">
        <xsl:value-of select="concat($label, ':')"/>
      </td>

      <td class="metavalue">
        <xsl:if test="string-length($user/user/realName) &gt; 0">
          <xsl:attribute name="title">
            <xsl:value-of select="$userid-with-realm"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="mcracl:checkPermission('POOLPRIVILEGE', 'administrate-users')">
            <a href="{$WebApplicationBaseURL}servlets/MCRUserServlet?action=show&amp;id={encoder:encode($userid-with-realm, 'UTF-8')}">
              <xsl:value-of select="$display-name"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$display-name"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
