<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" >

  <xsl:include href="modsmetadata-legacy.xsl" />

  <xsl:param name="MCR.Mods.SherpaRomeo.ApiKey" select="''" />


  <xsl:key use="mods:role/mods:roleTerm" name="name-by-role" match="mods:mods/mods:name" />

  <xsl:template match="mods:abstract" mode="present">
    <tr>
      <td valign="top" class="metaname">
        <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.abstract'),' (' ,@xml:lang,') :')" />
      </td>
      <td class="metavalue">
        <xsl:call-template name="lf2br">
          <xsl:with-param name="string" select="." />
        </xsl:call-template>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="mods:accessCondition" mode="present"><!-- ToDo: show cc icon and more information ... -->
    <tr>
      <td valign="top" class="metaname">
        <xsl:choose>
          <xsl:when test="@type">
            <xsl:value-of
              select="concat(mcri18n:translate(concat('component.mods.metaData.dictionary.accessCondition.',matches(@type,' ','_'))),':')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.accessCondition'),':')" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td class="metavalue">
        <xsl:choose>
          <xsl:when test="@type='use and reproduction'">
            <xsl:variable name="trimmed" select="normalize-space(.)" />
            <xsl:choose>
              <xsl:when test="contains($trimmed, 'cc_by')">
                <xsl:apply-templates select="." mode="cc-logo" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'rights_reserved')">
                <xsl:apply-templates select="." mode="rights_reserved" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'oa_nlz')">
                <xsl:apply-templates select="." mode="oa_nlz" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'oa')">
                <xsl:apply-templates select="." mode="oa-logo" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'ogl')">
                <xsl:apply-templates select="." mode="ogl-logo" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="." />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>



  <xsl:template match="children" mode="printChildren">
    <xsl:param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.contains')" />
    <!--*** List children per object type ************************************* -->
    <!-- 1.) get a list of objectTypes of all child elements 2.) remove duplicates from this list 3.) for-each objectTyp id list child elements -->
    <xsl:variable name="objectTypes">
      <xsl:for-each select="child/@xlink:href">
        <id>
          <xsl:copy-of select="substring-before(substring-after(.,'_'),'_')" />
        </id>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable select="$objectTypes/id[not(.=following::id)]" name="unique-ids" />
    <!-- the for-each would iterate over <id> with root not beeing /mycoreobject so we save the current node in variable context to access
      needed nodes -->
    <xsl:variable select="/mycoreobject" name="context" />
    <xsl:for-each select="$unique-ids">
      <xsl:variable select="." name="thisObjectType" />
      <xsl:variable name="children" select="$context/structure/children/child[contains(@xlink:href, concat('_',$thisObjectType,'_'))]" />
      <xsl:variable name="maxElements" select="20" />
      <xsl:variable name="positionMin">
        <xsl:choose>
          <xsl:when test="count($children) &gt; $maxElements">
            <xsl:value-of select="count($children) - $maxElements + 1" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="0" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$positionMin != 0">
          <!-- display recent $maxElements only -->
          <tr>
            <td valign="top" class="metaname">
              <xsl:value-of select="concat($label,':')" />
            </td>
            <td class="metavalue">
              <p>
                <xsl:choose>
                  <xsl:when test="not(mcracl:is-current-user-in-role('guest'))">
                    <a href="{$ServletsBaseURL}solr/parent?q={$context/@ID}&amp;fq=">
                      <xsl:value-of select="mcri18n:translate('component.mods.metaData.displayAll')" />
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="{$ServletsBaseURL}solr/parent?q={$context/@ID}">
                      <xsl:value-of select="mcri18n:translate('component.mods.metaData.displayAll')" />
                    </a>
                  </xsl:otherwise>
                </xsl:choose>
              </p>
              <xsl:for-each select="$children[position() &gt;= $positionMin]">
                <xsl:call-template name="objectLink">
                  <xsl:with-param name="obj_id" select="@xlink:href" />
                </xsl:call-template>
                <xsl:if test="position()!=last()">
                  <br />
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="printMetaDate">
            <xsl:with-param select="$children" name="nodes" />
            <xsl:with-param select="$label" name="label" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
