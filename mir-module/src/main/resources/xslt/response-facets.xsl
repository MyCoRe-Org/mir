<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:variable name="facetProperties" select="document(concat('property:','MIR.Response.Facet.*'))"/>

  <xsl:template name="facets">
    <xsl:for-each select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/*">
      <xsl:variable name="facet_name" select="self::node()/@name"/>

      <xsl:variable name="enabledProperty">
        <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.Enabled')]"/>
      </xsl:variable>
      <xsl:variable name="isEnabled" select="$enabledProperty!='false'"/>

      <xsl:variable name="rolesProperty">
        <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.Roles')]"/>
      </xsl:variable>
      <xsl:variable name="hasRole"
        select="string-length($rolesProperty)=0 or count(tokenize($rolesProperty, ',')[mcracl:is-current-user-in-role(.)])!=0"/>

      <xsl:if test="$isEnabled and $hasRole and self::node()[@name=$facet_name]/int">

        <xsl:variable name="classIdProperty">
          <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.ClassId')]"/>
        </xsl:variable>
        <xsl:variable name="classId">
          <xsl:choose>
            <xsl:when test="$classIdProperty!=''">
              <xsl:value-of select="$classIdProperty"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$facet_name"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="categoryClassValuesProperty">
          <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.CategoryClassValues')]"/>
        </xsl:variable>
        <xsl:variable name="categoryClassValues">
          <xsl:choose>
            <xsl:when test="$categoryClassValuesProperty!=''">
              <xsl:value-of select="$categoryClassValuesProperty"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="parameterValuesProperty">
          <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.ParameterValues')]"/>
        </xsl:variable>
        <xsl:variable name="parameterValues">
          <xsl:choose>
            <xsl:when test="$parameterValuesProperty!=''">
              <xsl:value-of select="$parameterValuesProperty"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <div class="card {$facet_name}">
          <div class="card-header" data-mcr-toggle="collapse-next">
            <h3 class="card-title">
              <xsl:choose>
                <xsl:when test="mcri18n:exists(concat('mir.response.facet.', $facet_name, '.title'))">
                  <xsl:value-of select="mcri18n:translate(concat('mir.response.facet.', $facet_name, '.title'))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="classification" select="document(concat('notnull:classification:metadata:0:children:', $classId))"/>
                  <xsl:choose>
                    <xsl:when test="not($classification/null)">
                      <xsl:variable name="label" select="$classification/mycoreclass/label[@xml:lang=$CurrentLang]/@text"/>
                      <xsl:choose>
                        <xsl:when test="string-length($label) &gt; 0">
                          <xsl:value-of select="$label"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="$facet_name"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$facet_name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </h3>
          </div>

          <div class="card-body collapse show">
            <ul class="filter">
              <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                <xsl:with-param name="facet_name" select="$facet_name"/>
                <xsl:with-param name="classId" select="$classId"/>
                <xsl:with-param name="categoryClassValues" select="$categoryClassValues='true'"/>
                <xsl:with-param name="parameterValues" select="$parameterValues='true'"/>
              </xsl:apply-templates>
            </ul>
          </div>
        </div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
    <xsl:param name="facet_name"/>
    <xsl:param name="classId" select="$facet_name"/>
    <xsl:param name="categoryClassValues" select="false()"/>
    <xsl:param name="parameterValues" select="false()"/>

    <xsl:for-each select="lst[@name=$facet_name]/int">
      <xsl:variable name="fqValue">
        <xsl:choose>
          <xsl:when test="$categoryClassValues = true()">
            <xsl:value-of
              select="concat('category.top',':',substring-before(@name,':'),'%5C:',substring-after(@name,':'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($facet_name,':',@name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="fqResponseValue">
        <xsl:choose>
          <xsl:when test="$categoryClassValues = true()">
            <xsl:value-of
              select="concat('category.top',':',substring-before(@name,':'),'\:',substring-after(@name,':'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($facet_name,':',@name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="fqFragment" select="concat('fq=',$fqValue)"/>
      <xsl:variable name="fqFragmentEncoded"
        select="concat('fq=', replace(encode-for-uri($fqResponseValue), '%20', '+'))"/>
      <xsl:variable name="queryWithoutStart" select="replace($RequestURL, '(&amp;|%26)(start=)[0-9]*', '')"/>

      <xsl:variable name="queryURL">
        <xsl:choose>
          <xsl:when test="contains($queryWithoutStart, $fqFragment)">
            <xsl:choose>
              <xsl:when test="not(substring-after($queryWithoutStart, $fqFragment))">
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

      <li data-fq="{$fqResponseValue}">
        <xsl:variable name="facetCheckboxId" select="concat('facet-', generate-id())" />
        <div class="form-check">
          <input id="{$facetCheckboxId}" type="checkbox" class="form-check-input" onchange="location.href='{$queryURL}';">
            <xsl:if test="
              /response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq' and text() = $fqResponseValue] |
              /response/lst[@name='responseHeader']/lst[@name='params']/arr[@name='fq']/str[text() = $fqResponseValue]">
              <xsl:attribute name="checked">true</xsl:attribute>
            </xsl:if>
          </input>

          <label for="{$facetCheckboxId}" class="form-check-label form-label">
            <span class="title">
              <xsl:call-template name="label">
                <xsl:with-param name="parameterValues" select="$parameterValues"/>
                <xsl:with-param name="categoryClassValues" select="$categoryClassValues"/>
                <xsl:with-param name="classId" select="$classId"/>
                <xsl:with-param name="facet_name" select="$facet_name"/>
              </xsl:call-template>
            </span>
            <span class="hits">
              <xsl:value-of select="."/>
            </span>
          </label>
        </div>
      </li>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="label">
    <xsl:param name="parameterValues"/>
    <xsl:param name="categoryClassValues"/>
    <xsl:param name="classId"/>
    <xsl:param name="facet_name"/>
    <xsl:choose>
      <xsl:when test="$parameterValues">
        <xsl:variable name="parameterValue"
          select="string((/response/lst[@name='responseHeader']/lst[@name='params']/str[@name=concat('facet.label.', @name)])[1])"/>
        <xsl:choose>
          <xsl:when test="string-length($parameterValue)!=0">
            <xsl:value-of select="$parameterValue"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="label">
              <xsl:with-param name="parameterValues" select="false()"/>
              <xsl:with-param name="categoryClassValues" select="$categoryClassValues"/>
              <xsl:with-param name="classId" select="$classId"/>
              <xsl:with-param name="facet_name" select="$facet_name"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when
          test="$categoryClassValues = true() and mcrclassification:is-category-id(substring-before(@name, ':'), substring-after(@name, ':'))">
        <xsl:value-of
          select="mcrclassification:current-label-text(mcrclassification:category(substring-before(@name, ':'), substring-after(@name, ':')))"/>
      </xsl:when>
      <xsl:when test="mcrclassification:is-category-id($classId, @name)">
        <xsl:value-of select="mcrclassification:current-label-text(mcrclassification:category($classId, @name))"/>
      </xsl:when>
      <xsl:when test="mcri18n:exists(concat('mir.response.facet.' ,$facet_name, '.value.', @name))">
        <xsl:copy-of
          select="parse-xml-fragment(mcri18n:translate(concat('mir.response.facet.' ,$facet_name, '.value.', @name)))/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
