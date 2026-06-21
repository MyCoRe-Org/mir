<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" >

  <xsl:template name="printMetaDate">
    <!-- prints a table row for a given nodeset -->
    <xsl:param name="nodes" />
    <xsl:param name="label" select="local-name($nodes[1])" />

    <xsl:if test="$nodes">
      <tr id="metadata_{local-name($nodes[1])}" class="metadata_{substring-before(substring-after(@ID,'_'),'_')}_{local-name($nodes[1])}">
        <td valign="top" class="metaname">
          <xsl:value-of select="concat($label,':')" />
        </td>
        <td class="metavalue">
          <xsl:variable name="selectPresentLang" select="mcri18n:select-present-lang($nodes)"/>
          <xsl:for-each select="$nodes">
            <xsl:choose>
              <xsl:when test="../@class='MCRMetaClassification'">
                <xsl:call-template name="printClass">
                  <xsl:with-param name="nodes" select="." />
                  <xsl:with-param name="next" select="'&lt;br /&gt;'" />
                </xsl:call-template>
                <xsl:call-template name="printClassInfo">
                  <xsl:with-param name="nodes" select="." />
                  <xsl:with-param name="next" select="'&lt;br /&gt;'" />
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="../@class='MCRMetaISO8601Date'">
                <xsl:variable name="normalized" select="mirdateconverter:convert-date(., 'ISO8601')"/>
                <xsl:choose>
                  <xsl:when test="matches($normalized, '^\d{4}$')">
                    <xsl:value-of select="$normalized"/>
                  </xsl:when>
                  <xsl:when test="matches($normalized, '^\d{4}-\d{2}$')">
                    <xsl:value-of select="$normalized"/>
                  </xsl:when>
                  <xsl:when test="matches($normalized, '^\d{4}-\d{2}-\d{2}$')">
                    <xsl:value-of select="format-date(xs:date($normalized), mcri18n:translate('metaData.dateYearMonthDay.xsl3'))"/>
                  </xsl:when>
                  <xsl:when test="$normalized castable as xs:dateTime">
                    <xsl:value-of select="format-dateTime(xs:dateTime($normalized), mcri18n:translate('metaData.dateTime.xsl3'))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$normalized"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="../@class='MCRMetaHistoryDate'">
                <xsl:if test="not(@xml:lang) or @xml:lang=$selectPresentLang">
                  <xsl:call-template name="printHistoryDate">
                    <xsl:with-param name="nodes" select="." />
                    <xsl:with-param name="next" select="', '" />
                  </xsl:call-template>
                </xsl:if>
              </xsl:when>
              <xsl:when test="../@class='MCRMetaLinkID'">
                <xsl:call-template name="objectLink">
                  <xsl:with-param name="obj_id" select="@xlink:href" />
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="@class='MCRMetaDerivateLink'">
                <xsl:call-template name="derivateLink" />
              </xsl:when>
              <xsl:when test="../@class='MCRMetaLink'">
                <xsl:call-template name="webLink">
                  <xsl:with-param name="nodes" select="$nodes" />
                  <xsl:with-param name="next" select="'&lt;br /&gt;'" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="not(@xml:lang) or @xml:lang=$selectPresentLang">
                  <xsl:call-template name="printI18N">
                    <xsl:with-param name="nodes" select="." />
                    <xsl:with-param name="next" select="'&lt;br /&gt;'" />
                  </xsl:call-template>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position()!=last()">
              <br />
            </xsl:if>
          </xsl:for-each>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template name="derivateLink">
    <xsl:for-each select="derivateLink">
      <xsl:variable name="derivateId" select="substring-before(@xlink:href, '/')" />
      <xsl:variable name="isDisplayedEnabled" select="mcracl:check-permission($derivateId,'read') or mcracl:check-permission($derivateId,'view')" />
      <xsl:variable name="mayWriteDerivate" select="mcracl:check-permission($derivateId,'writedb')" />
      <xsl:choose>
        <xsl:when test="$isDisplayedEnabled or $mayWriteDerivate">
          <xsl:variable name="firstSupportedFile" select="concat('/', substring-after(@xlink:href, '/'))" />
          <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr>
              <xsl:if test="annotation">
                <xsl:value-of select="annotation" />
                <br />
              </xsl:if>
            </tr>
            <tr>
              <td valign="top" align="left">
                <!-- MCR-IView ..start -->
                <xsl:call-template name="derivateLinkView">
                  <xsl:with-param name="derivateID" select="$derivateId" />
                  <xsl:with-param name="file" select="$firstSupportedFile" />
                </xsl:call-template>
                <!-- MCR - IView ..end -->
              </td>
            </tr>
          </table>
        </xsl:when>
        <xsl:otherwise>
          <p>
            <!-- Zugriff auf 'Abbildung' gesperrt -->
            <xsl:variable select="substring-before(substring-after(/@ID,'_'),'_')" name="type" />
            <xsl:value-of select="mcri18n:translate-with-params('metaData.derivateLocked',mcri18n:translate(concat('metaData.',$type,'.[derivates]')))" />
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="webLink">
    <xsl:param name="nodes" />
    <xsl:param name="next" />
    <xsl:for-each select="$nodes">
      <xsl:if test="position() != 1">
        <xsl:value-of select="$next" disable-output-escaping="yes" />
      </xsl:if>
      <xsl:variable name="href" select="@xlink:href" />
      <xsl:variable name="title">
        <xsl:choose>
          <xsl:when test="@xlink:title">
            <xsl:value-of select="@xlink:title" />
          </xsl:when>
          <xsl:when test="@xlink:label">
            <xsl:value-of select="@xlink:label" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@xlink:href" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <a href="{@xlink:href}">
        <xsl:value-of select="$title" />
      </a>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="printI18N">
    <xsl:param name="nodes" />
    <xsl:param name="next" />
    <xsl:variable name="selectPresentLang" select="mcri18n:select-present-lang($nodes)"/>
    <xsl:choose>
      <xsl:when test="string-length($selectPresentLang)">
        <xsl:for-each select="$nodes[lang($selectPresentLang)]">
          <xsl:if test="position() != 1">
            <xsl:value-of select="$next" disable-output-escaping="yes" />
          </xsl:if>
          <xsl:call-template name="lf2br">
            <xsl:with-param name="string" select="." />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$nodes">
          <xsl:if test="position() != 1">
            <xsl:value-of select="$next" disable-output-escaping="yes" />
          </xsl:if>
          <xsl:call-template name="lf2br">
            <xsl:with-param name="string" select="." />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="objectLink">
    <!-- specify either one of them -->
    <xsl:param name="obj_id" />
    <xsl:param name="mcrobj" />
    <xsl:choose>
      <xsl:when test="$mcrobj">
        <xsl:variable name="obj_id" select="$mcrobj/@ID" />
        <xsl:choose>
          <xsl:when test="mcracl:check-permission($obj_id,'read')">
            <a href="{$WebApplicationBaseURL}receive/{$obj_id}">
              <xsl:attribute name="title"><xsl:apply-templates select="$mcrobj" mode="fulltitle" /></xsl:attribute>
              <xsl:apply-templates select="$mcrobj" mode="resulttitle" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <!-- Build Login URL for LoginServlet -->
            <xsl:variable name="LoginURL" select="$LoginDetourURL" />
            <xsl:apply-templates select="$mcrobj" mode="resulttitle" />
            &#160;
            <a href="{$LoginURL}">
              <img src="{concat($WebApplicationBaseURL,'images/paper_lock.gif')}" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="string-length($obj_id)&gt;0">
        <!-- handle old way which may cause a double parsing of mcrobject: -->
        <xsl:variable name="mcrobj" select="document(concat('mcrobject:',$obj_id))/mycoreobject" />
        <xsl:choose>
          <xsl:when test="mcracl:check-permission($obj_id,'read')">
            <a href="{$WebApplicationBaseURL}receive/{$obj_id}">
              <xsl:apply-templates select="$mcrobj" mode="resulttitle" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <!-- Build Login URL for LoginServlet -->
            <xsl:variable name="LoginURL" select="$LoginDetourURL" />
            <xsl:apply-templates select="$mcrobj" mode="resulttitle" />
            &#160;
            <a href="{$LoginURL}">
              <img src="{concat($WebApplicationBaseURL,'images/paper_lock.gif')}" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="printHistoryDate">
    <xsl:param name="nodes" />
    <xsl:param name="next" />
    <xsl:variable name="selectLang" select="mcri18n:select-lang($nodes)"/>
    <xsl:for-each select="$nodes[lang($selectLang)]">
      <xsl:if test="position() != 1">
        <xsl:value-of select="$next" disable-output-escaping="yes" />
      </xsl:if>
      <xsl:value-of select="text" />
      <xsl:text> (</xsl:text>
      <xsl:value-of select="von" />
      <xsl:text> - </xsl:text>
      <xsl:value-of select="bis" />
      <xsl:text> )</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="printClass">
    <xsl:param name="nodes" />
    <xsl:param name="next" select="''" />
    <xsl:for-each select="$nodes">
      <xsl:if test="position() != 1">
        <xsl:value-of select="$next" disable-output-escaping="yes" />
      </xsl:if>
      <xsl:for-each select="mcrclassification:category(@classid,@categid)">
        <xsl:variable name="categurl">
          <xsl:if test="url">
            <xsl:choose>
              <!-- MCRObjectID should not contain a ':' so it must be an external link then -->
              <xsl:when test="contains(url/@xlink:href,':')">
                <xsl:value-of select="url/@xlink:href" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',url/@xlink:href)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="selectLang" select="mcri18n:select-lang(./label)" />
        <xsl:for-each select="./label[lang($selectLang)]">
          <xsl:choose>
            <xsl:when test="string-length($categurl) != 0">
              <a href="{$categurl}">
                <xsl:value-of select="@text" />
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@text" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="printClassInfo">
    <xsl:param name="nodes" />
    <xsl:param name="next" />
    <xsl:for-each select="$nodes">
      <xsl:if test="position() != 1">
        <xsl:value-of select="$next" disable-output-escaping="yes" />
      </xsl:if>
      <xsl:for-each select="mcrclassification:category(@classid,@categid)">
        <xsl:variable name="categurl">
          <xsl:if test="url">
            <xsl:choose>
              <!-- MCRObjectID should not contain a ':' so it must be an external link then -->
              <xsl:when test="contains(url/@xlink:href,':')">
                <xsl:value-of select="url/@xlink:href" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',url/@xlink:href)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="selectLang" select="mcri18n:select-lang(./label)" />
        <xsl:for-each select="./label[lang($selectLang) and @description]">
          <xsl:choose>
            <xsl:when test="string-length($categurl) != 0">
              <a href="{$categurl}">
                <xsl:value-of select="concat('(',@description,')')" />
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('(',@description,')')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="lf2br">
    <xsl:param name="string" as="xs:string" />

    <xsl:for-each select="tokenize($string, '\r?\n')">
      <xsl:value-of select="." />
      <xsl:if test="position() ne last()">
        <br />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
