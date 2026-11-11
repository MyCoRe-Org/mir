<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='create-child']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="mods-type" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="(not($guest) or $write) and mcracl:check-permission('', 'create-mods') and doc-available('resource:actionmappings.xml')">
      <xsl:variable name="genres" select="
        document('classification:metadata:-1:children:mir_genres')
          //category[contains(label[@xml:lang='x-hosts']/@text, $mods-type)]/@ID/string()
      " />
      <xsl:if test="exists($genres)">
        <xsl:variable name="url" select="mcractionmapping:get-url-for-id('create-child', $object-id, true())" />
        <xsl:variable name="is-dynamic-editor" select="contains($url, 'editor-dynamic.xed')" />
        <xsl:variable name="is-lecture-child" select="$is-dynamic-editor and $mods-type = 'lecture'" />
        <xsl:variable name="related-item-type" select="
          if ($is-lecture-child or (not($is-dynamic-editor) and $mods-type = 'series')) then 'series' else 'host'
        " />
        <xsl:variable name="host-param" select="if ($is-lecture-child) then concat('&amp;host=', $mods-type) else ''" />
        <xsl:for-each select="$genres">
          <li>
            <a href="{$url}?relatedItemId={$object-id}&amp;relatedItemType={$related-item-type}&amp;genre={.}{$host-param}" class="dropdown-item">
              <xsl:value-of select="mcrclassification:current-label-text(mcrclassification:category('mir_genres', .))" />
            </a>
          </li>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
