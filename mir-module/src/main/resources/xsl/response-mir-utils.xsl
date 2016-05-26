<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl i18n"
>

  <xsl:template name="browse.Pagination">
    <xsl:param name="id" select="'pagination'" />
    <xsl:param name="i18nprefix" select="'mir.pagination.hits'" />
    <xsl:param name="class" select="''" />

    <xsl:param name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />

    <xsl:param name="page" />
    <xsl:param name="pages" />

    <xsl:variable name="label.previousHit" select="i18n:translate(concat($i18nprefix, '.previous'), $page - 1)" />
    <xsl:variable name="label.nextHit" select="i18n:translate(concat($i18nprefix, '.next'), $page + 1)" />

    <div id="{$id}" class="row {$class}">
      <xsl:if test="$page &gt; 1">
        <xsl:variable name="link">
          <xsl:call-template name="paginateLink">
            <xsl:with-param name="href" select="$href" />
            <xsl:with-param name="page" select="$page - 1" />
            <xsl:with-param name="numPerPage" select="1" />
          </xsl:call-template>
        </xsl:variable>
        <div class="col-xs-12 col-md-5 text-left">
          <a tabindex="0" class="previous" href="{$link}" data-pagination=".caption:mods.title.main">
            <span class="glyphicon glyphicon-chevron-left icon" />
            <span class="caption">
              <xsl:value-of select="$label.previousHit" />
            </span>
          </a>
        </div>
      </xsl:if>
      <div class="col-xs-12 col-md-2 text-center">
        <xsl:attribute name="class">
          <xsl:text>col-xs-12 col-md-2 text-center</xsl:text>
          <xsl:if test="$page = 1">
            <xsl:text> col-md-offset-5</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="i18n:translate(concat($i18nprefix, '.entriesInfo'), concat($page, ';', $pages))" />
      </div>
      <xsl:if test="$page &lt; $pages">
        <xsl:variable name="link">
          <xsl:call-template name="paginateLink">
            <xsl:with-param name="href" select="$href" />
            <xsl:with-param name="page" select="$page + 1" />
            <xsl:with-param name="numPerPage" select="1" />
          </xsl:call-template>
        </xsl:variable>
        <div class="col-xs-12 col-md-5 text-right">
          <a tabindex="0" class="next" href="{$link}" data-pagination=".caption:mods.title.main">
            <span class="glyphicon glyphicon-chevron-right icon" />
            <span class="caption">
              <xsl:value-of select="$label.nextHit" />
            </span>
          </a>
        </div>
      </xsl:if>
    </div>

    <script type="text/javascript">
      <![CDATA[
        $(document).ready(function() {
          var replaceUrlParam = function(url, paramName, paramValue) {
            var pattern = new RegExp('\\b(' + paramName + '=).*?(&|$)')
            if (url.search(pattern) >= 0) {
              return url.replace(pattern, '$1' + paramValue + '$2');
            }
            return url + (url.indexOf('?') > 0 ? '&' : '?') + paramName + '=' + paramValue
          }
        
          $("*[data-pagination]").each(function() {
            var $this = $(this);
            var sel = /([^\:]*)\:(.*)/.exec($(this).data("pagination")).slice(1);
        
            if (sel && sel.length > 1) {
              var url = replaceUrlParam(replaceUrlParam($(this).attr("href"), "XSL.Style", "xml"), "fl", sel[1]);
              $.ajax(url).done(function(data) {
                var $xml = $(data);
                var title = $xml.find("*[name='" + sel[1] + "']").text();
                if (title) {
                  $this.attr("title", title);
                  $(sel[0], $this).text(title);
                }
              });
            }
          });
        });
      ]]>
    </script>
  </xsl:template>

  <xsl:template name="resultList.Pagination">
    <xsl:param name="id" select="'pagination'" />
    <xsl:param name="i18nprefix" select="'mir.pagination'" />
    <xsl:param name="class" select="''" />

    <xsl:param name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />

    <!-- variable can be used to change numbers of Page entries to display -->
    <xsl:param name="maxEntries" select="7" />
    <xsl:param name="maxEntries-mobile" select="5" />

    <xsl:param name="numPerPage" />
    <xsl:param name="page" />
    <xsl:param name="pages" />

    <xsl:variable name="label.firstPage" select="i18n:translate(concat($i18nprefix, '.first'), 1)" />
    <xsl:variable name="label.lastPage" select="i18n:translate(concat($i18nprefix, '.last'), $pages)" />
    <xsl:variable name="label.previousPage" select="i18n:translate(concat($i18nprefix, '.previous'), $page - 1)" />
    <xsl:variable name="label.nextPage" select="i18n:translate(concat($i18nprefix, '.next'), $page + 1)" />

    <ul id="{$id}-paginate" class="pagination {$class}">
      <li>
        <xsl:choose>
          <xsl:when test="number($page) &gt; 1">
            <a tabindex="0" id="{$id}-first" title="{$label.firstPage}">
              <xsl:attribute name="href">
                <xsl:call-template name="paginateLink">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="page" select="1" />
                  <xsl:with-param name="numPerPage" select="$numPerPage" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;laquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.firstPage" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;laquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.firstPage" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <li>
        <xsl:choose>
          <xsl:when test="number($page) &gt; 1">
            <a tabindex="0" id="{$id}-previous" title="{$label.previousPage}">
              <xsl:attribute name="href">
                  <xsl:call-template name="paginateLink">
                    <xsl:with-param name="href" select="$href" />
                    <xsl:with-param name="page" select="$page - 1" />
                    <xsl:with-param name="numPerPage" select="$numPerPage" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;lsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.previousPage" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;lsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.previousPage" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>

      <xsl:variable name="paginateStart">
        <xsl:call-template name="paginateStart">
          <xsl:with-param name="maxEntries" select="$maxEntries" />
          <xsl:with-param name="page" select="$page" />
          <xsl:with-param name="pages" select="$pages" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="paginateEnd">
        <xsl:call-template name="paginateEnd">
          <xsl:with-param name="maxEntries" select="$maxEntries" />
          <xsl:with-param name="page" select="$page" />
          <xsl:with-param name="pages" select="$pages" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="paginateStart-mobile">
        <xsl:call-template name="paginateStart">
          <xsl:with-param name="maxEntries" select="$maxEntries-mobile" />
          <xsl:with-param name="page" select="$page" />
          <xsl:with-param name="pages" select="$pages" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="paginateEnd-mobile">
        <xsl:call-template name="paginateEnd">
          <xsl:with-param name="maxEntries" select="$maxEntries-mobile" />
          <xsl:with-param name="page" select="$page" />
          <xsl:with-param name="pages" select="$pages" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="paginateEntries">
        <xsl:with-param name="href" select="$href" />
        <xsl:with-param name="numPerPage" select="$numPerPage" />
        <xsl:with-param name="page" select="$page" />
        <xsl:with-param name="pages" select="$pages" />
        <xsl:with-param name="paginateStart" select="$paginateStart" />
        <xsl:with-param name="paginateEnd" select="$paginateEnd" />
        <xsl:with-param name="paginateStart-mobile" select="$paginateStart-mobile" />
        <xsl:with-param name="paginateEnd-mobile" select="$paginateEnd-mobile" />
      </xsl:call-template>

      <li>
        <xsl:choose>
          <xsl:when test="number($page) &lt; $pages">
            <a tabindex="0" id="{$id}-next" title="{$label.nextPage}">
              <xsl:attribute name="href">
                <xsl:call-template name="paginateLink">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="page" select="$page + 1" />
                  <xsl:with-param name="numPerPage" select="$numPerPage" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;rsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.nextPage" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;rsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.nextPage" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <li>
        <xsl:choose>
          <xsl:when test="number($page) &lt; $pages">
            <a tabindex="0" id="{$id}-last" title="{$label.lastPage}">
              <xsl:attribute name="href">
                <xsl:call-template name="paginateLink">
                  <xsl:with-param name="href" select="$href" />
                  <xsl:with-param name="page" select="$pages" />
                  <xsl:with-param name="numPerPage" select="$numPerPage" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;raquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.lastPage" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;raquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="$label.lastPage" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </ul>
  </xsl:template>

  <xsl:template name="paginateStart">
    <xsl:param name="maxEntries" />
    <xsl:param name="page" />
    <xsl:param name="pages" />

    <xsl:variable name="paginateBackCount" select="ceiling(($maxEntries - 1) div 2)" />
    <xsl:variable name="paginatePrevCount" select="$maxEntries - ceiling($maxEntries div 2)" />

    <xsl:choose>
      <xsl:when test="((number($page) - $paginateBackCount) &lt;= 1) or ($pages &lt; $maxEntries)">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:when test="(number($page) + $paginatePrevCount) &gt; $pages">
        <xsl:value-of select="number($page) - $paginateBackCount - ((number($page) + $paginatePrevCount) - $pages)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number($page) - $paginateBackCount" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="paginateEnd">
    <xsl:param name="maxEntries" />
    <xsl:param name="page" />
    <xsl:param name="pages" />

    <xsl:variable name="paginateBackCount" select="ceiling(($maxEntries - 1) div 2)" />
    <xsl:variable name="paginatePrevCount" select="$maxEntries - ceiling($maxEntries div 2)" />

    <xsl:choose>
      <xsl:when test="((number($page) + $paginatePrevCount) &gt;= $pages) or ($pages &lt; $maxEntries)">
        <xsl:value-of select="$pages" />
      </xsl:when>
      <xsl:when test="(number($page) + $paginatePrevCount) &lt; $maxEntries">
        <xsl:value-of select="$maxEntries" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number($page) + $paginatePrevCount" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="paginateEntries">
    <xsl:param name="href" />
    <xsl:param name="numPerPage" />
    <xsl:param name="page" />
    <xsl:param name="pages" />
    <xsl:param name="paginateStart" />
    <xsl:param name="paginateEnd" />
    <xsl:param name="paginateStart-mobile" />
    <xsl:param name="paginateEnd-mobile" />

    <xsl:if test="$paginateStart = number($page)">
      <li class="active">
        <span>
          <xsl:value-of select="$paginateStart" />
        </span>
      </li>
    </xsl:if>
    <xsl:if test="$paginateStart != number($page)">
      <li>
        <xsl:if test="($paginateStart &lt; $paginateStart-mobile) or ($paginateStart &gt; $paginateEnd-mobile)">
          <xsl:attribute name="class">hidden-xs</xsl:attribute>
        </xsl:if>
        <a tabindex="0">
          <xsl:attribute name="href">
            <xsl:call-template name="paginateLink">
              <xsl:with-param name="href" select="$href" />
              <xsl:with-param name="page" select="$paginateStart" />
              <xsl:with-param name="numPerPage" select="$numPerPage" />
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="$paginateStart" />
        </a>
      </li>
    </xsl:if>

    <xsl:if test="$paginateStart &lt; $paginateEnd">
      <xsl:call-template name="paginateEntries">
        <xsl:with-param name="href" select="$href" />
        <xsl:with-param name="numPerPage" select="$numPerPage" />
        <xsl:with-param name="page" select="$page" />
        <xsl:with-param name="pages" select="$pages" />
        <xsl:with-param name="paginateStart" select="$paginateStart + 1" />
        <xsl:with-param name="paginateEnd" select="$paginateEnd" />
        <xsl:with-param name="paginateStart-mobile" select="$paginateStart-mobile" />
        <xsl:with-param name="paginateEnd-mobile" select="$paginateEnd-mobile" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="paginateLink">
    <xsl:param name="href" />
    <xsl:param name="page" select="1" />
    <xsl:param name="numPerPage" />

    <xsl:value-of select="concat($href, '&amp;start=',(($page -1) * $numPerPage), '&amp;rows=', $numPerPage)" />
  </xsl:template>

</xsl:stylesheet>