<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:encoder="xalan://java.net.URLEncoder"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="i18n mcrxsl encoder fn"
>
  <xsl:template name="facets">
    <xsl:if test="/response/lst[@name='facet_counts']/lst[@name='facet_fields'] !=''">
      <xsl:for-each select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/*">
        <xsl:variable name="facet_name" select="self::node()/@name"/>
        <!-- TODO: remove conditions for facets 'worldReadableComplete' and 'mods.genre' after code refactoring -->
        <xsl:if test="self::node()[@name=$facet_name]/int">
          <div class="card {$facet_name}">
            <div class="card-header" data-toggle="collapse-next">
              <h3 class="card-title">
                <!-- Checking facet name for compatibility with old code, facets named -->
                <!-- 'worldReadableComplete' and 'mods.genre' from old code -->
                <xsl:choose>
                  <!-- facet 'worldReadableComplete' -->
                  <xsl:when test="$facet_name='worldReadableComplete'">
                    <xsl:value-of select="i18n:translate('mir.response.openAccess.facet.title')"/>
                  </xsl:when>

                  <!-- facet 'mods.genre' -->
                  <xsl:when test="$facet_name='mods.genre'">
                    <xsl:value-of select="i18n:translate('editor.search.mir.genre')"/>
                  </xsl:when>

                  <!-- all other facets -->
                  <xsl:otherwise>
                    <!-- If there is no value in the messages_*.properties files, then we take the facet name as the title of the card -->
                    <xsl:choose>
                      <xsl:when
                        test="fn:matches(i18n:translate(concat('mir.response.facet.', $facet_name, '.title')),'^\?\?\?(.*?)\?\?\?$')">
                        <xsl:value-of select="$facet_name"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of
                          select="i18n:translate(concat('mir.response.facet.', $facet_name, '.title'))"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </h3>
            </div>

            <div class="card-body collapse show">
              <ul class="filter">
                <!-- Checking facet name for compatibility with old code, facets named -->
                <!-- 'worldReadableComplete' and 'mods.genre' from old code -->
                <xsl:choose>
                  <!-- facet 'worldReadableComplete' -->
                  <xsl:when test="$facet_name='worldReadableComplete'">
                    <xsl:apply-templates
                      select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                      <xsl:with-param name="facet_name" select="$facet_name"/>
                      <xsl:with-param name="i18nPrefix"
                                      select="'mir.response.openAccess.facet.'"/>
                    </xsl:apply-templates>
                  </xsl:when>

                  <!-- facet 'mods.genre' -->
                  <xsl:when test="$facet_name='mods.genre'">
                    <xsl:apply-templates
                      select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                      <xsl:with-param name="facet_name" select="$facet_name"/>
                      <xsl:with-param name="classId" select="'mir_genres'"/>
                    </xsl:apply-templates>
                  </xsl:when>

                  <!-- all other facets -->
                  <xsl:otherwise>
                    <xsl:apply-templates
                      select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                      <xsl:with-param name="facet_name" select="$facet_name"/>
                      <xsl:with-param name="classId" select="$facet_name"/>
                    </xsl:apply-templates>
                  </xsl:otherwise>
                </xsl:choose>
              </ul>
            </div>
          </div>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

  </xsl:template>

  <xsl:template match="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
    <xsl:param name="facet_name"/>
    <xsl:param name="classId"/>
    <xsl:param name="i18nPrefix"/>

    <xsl:for-each select="lst[@name=$facet_name]/int">
      <xsl:variable name="fqValue" select="concat($facet_name,':',@name)"/>
      <xsl:variable name="fqFragment" select="concat('fq=',$fqValue)"/>
      <xsl:variable name="fqFragmentEncoded" select="concat('fq=',encoder:encode($fqValue, 'UTF-8'))"/>
      <xsl:variable name="queryWithoutStart"
                    select="mcrxsl:regexp($RequestURL, '(&amp;|%26)(start=)[0-9]*', '')"/>
      <xsl:variable name="queryURL">
        <xsl:choose>
          <xsl:when test="contains($queryWithoutStart, $fqFragment)">
            <xsl:choose>
              <xsl:when test="not(substring-after($queryWithoutStart, $fqFragment))">
                <!-- last parameter -->
                <xsl:value-of
                  select="substring($queryWithoutStart, 1, string-length($queryWithoutStart) - string-length($fqFragment) - 1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat(substring-before($queryWithoutStart, $fqFragment), substring-after($queryWithoutStart, concat($fqFragment,'&amp;')))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="contains($queryWithoutStart, $fqFragmentEncoded)">
            <xsl:choose>
              <xsl:when test="not(substring-after($queryWithoutStart, $fqFragmentEncoded))">
                <!-- last parameter -->
                <xsl:value-of
                  select="substring($queryWithoutStart, 1, string-length($queryWithoutStart) - string-length($fqFragmentEncoded) - 1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat(substring-before($queryWithoutStart, $fqFragmentEncoded), substring-after($queryWithoutStart, concat($fqFragmentEncoded,'&amp;')))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="not(contains($queryWithoutStart, '?'))">
            <xsl:value-of select="concat($queryWithoutStart, '?', $fqFragment)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($queryWithoutStart, '&amp;', $fqFragment)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <li data-fq="{$fqValue}">
        <div class="custom-control custom-checkbox" onclick="location.href='{$queryURL}';">
          <input type="checkbox" class="custom-control-input">
            <xsl:if test="
              /response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq' and text() = $fqValue] |
              /response/lst[@name='responseHeader']/lst[@name='params']/arr[@name='fq']/str[text() = $fqValue]">
              <xsl:attribute name="checked">true</xsl:attribute>
            </xsl:if>
          </input>
          <label class="custom-control-label">
            <span class="title">
              <xsl:choose>
                <xsl:when test="string-length($classId) &gt; 0">
                  <xsl:variable name="displayName" select="mcrxsl:getDisplayName($classId, @name)"/>
                  <xsl:choose>
                    <xsl:when test="displayName">
                      <xsl:value-of select="$displayName"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="@name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="string-length($i18nPrefix) &gt; 0">
                  <xsl:value-of select="i18n:translate(concat($i18nPrefix,@name))"
                                disable-output-escaping="yes"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@name"/>
                </xsl:otherwise>
              </xsl:choose>
            </span>
            <span class="hits">
              <xsl:value-of select="."/>
            </span>
          </label>
        </div>
      </li>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
