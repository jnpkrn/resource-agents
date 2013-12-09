<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:int="__internal__"
    xmlns:rha="http://redhat.com/~pkennedy/annotation_namespace/cluster_conf_annot_namespace"
    exclude-result-prefixes="int">
    <xsl:output method="text" indent="no"/>

<xsl:param name="global-init-indent" select="'  '"/>
<xsl:param name="global-indent" select="'  '"/>


<!--
  helper definitions
  -->

<int:agent-parameter-specialization>
    <!-- int:agent @name="..." > int:parameter @name="..." > PATTERN -->
    <!-- SCRIPT -->
    <int:agent name="script">
        <int:parameter name="file">
            <data type="token">
                <except>
                    <data type="token">
                        <!-- disallow cluster to control its own core services through a "script" RA -->
                        <param name="pattern">/etc/(rc\.d/)?init\.d/(cman|rgmanager)(\s.*|)</param>
                    </data>
                </except>
            </data>
        </int:parameter>
    </int:agent>
</int:agent-parameter-specialization>

<xsl:variable name="SP" select="' '"/>
<xsl:variable name="NL" select="'&#xA;'"/>
<xsl:variable name="NLNL" select="'&#xA;&#xA;'"/>
<xsl:variable name="Q" select="'&quot;'"/>
<xsl:variable name="TS" select="'&lt;'"/>
<xsl:variable name="TSc" select="'&lt;/'"/>
<xsl:variable name="TE" select="'&gt;'"/>
<xsl:variable name="TEc" select="'/&gt;'"/>

<xsl:template name="comment">
    <xsl:param name="text" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="concat($TS, '!-- ', normalize-space($text), ' --',$TE)"/>
</xsl:template>

<xsl:template name="text">
    <xsl:param name="text" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="normalize-space($text)"/>
</xsl:template>

<xsl:template name="tag-start">
    <xsl:param name="name"/>
    <xsl:param name="attrs" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="concat($TS, $name)"/>
    <xsl:if test="$attrs != ''">
        <xsl:value-of select="concat($SP, normalize-space($attrs))"/>
    </xsl:if>
    <xsl:value-of select="$TE"/>
</xsl:template>

<xsl:template name="tag-end">
    <xsl:param name="name"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:if test="$indent != 'NONE'">
        <xsl:value-of select="concat($indented, $indent)"/>
    </xsl:if>
    <xsl:value-of select="concat($TSc, $name)"/>
    <xsl:value-of select="$TE"/>
</xsl:template>

<xsl:template name="pretty-print">
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:param name="fill-with"/>
    <!--xsl:value-of select="$NL"/-->
    <xsl:for-each select="$fill-with">
        <xsl:choose>
            <xsl:when test="self::comment()">
                <xsl:value-of select="$NL"/>
                <xsl:call-template name="comment">
                    <xsl:with-param name="text" select="."/>
                    <xsl:with-param name="indent" select="$indent"/>
                    <xsl:with-param name="indented" select="concat($indented, $indent)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="self::*">
                <xsl:if test="count(preceding-sibling::*) = 0
                              or
                                  (preceding-sibling::node()[comment() or *])[last()]
                                  !=
                                  preceding-sibling::*[last()]">
                    <xsl:value-of select="$NL"/>
                </xsl:if>
                <xsl:call-template name="tag">
                    <xsl:with-param name="name" select="name()"/>
                    <xsl:with-param name="attrs">
                        <xsl:for-each select="@*">
                            <xsl:value-of select="concat(name(), '=', $Q, ., $Q, $SP)"/>
                        </xsl:for-each>
                    </xsl:with-param>
                    <xsl:with-param name="indent" select="$indent"/>
                    <xsl:with-param name="indented" select="concat($indented, $indent)"/>
                    <xsl:with-param name="fill-with"
                                    select="node()"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>
            </xsl:when>
            <xsl:when test="self::text()">
                <xsl:call-template name="text">
                    <xsl:with-param name="text" select="."/>
                    <xsl:with-param name="indent" select="'NONE'"/>
                    <xsl:with-param name="indented" select="$indented"/>
                </xsl:call-template>
                <!-- xsl:value-of select="$NL"/ -->
            </xsl:when>
            <xsl:value-of select="name()"/>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template name="tag">
    <xsl:param name="name"/>
    <xsl:param name="attrs" select="''"/>
    <xsl:param name="indent" select="$global-indent"/>
    <xsl:param name="indented" select="''"/>
    <xsl:param name="fill-with" select="false()"/>
    <xsl:choose>
        <!-- XXX: better test for "empty" fill-with -->
        <xsl:when test="$fill-with != false()">
            <xsl:call-template name="tag-start">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="attrs" select="$attrs"/>
                <xsl:with-param name="indent" select="$indent"/>
                <xsl:with-param name="indented" select="$indented"/>
            </xsl:call-template>
            <xsl:call-template name="pretty-print">
                <xsl:with-param name="indent" select="$indent"/>
                <xsl:with-param name="indented" select="$indented"/>
                <xsl:with-param name="fill-with" select="$fill-with"/>
            </xsl:call-template>
            <xsl:call-template name="tag-end">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="indent">
                    <xsl:choose>
                        <xsl:when test="count($fill-with) = 1
                                        and $fill-with[1][self::text()]">
                            <xsl:value-of select="'NONE'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$indent"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="indented" select="$indented"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="$indent != 'NONE'">
                <xsl:value-of select="concat($indented, $indent)"/>
            </xsl:if>
            <xsl:value-of select="concat($TS, $name)"/>
            <xsl:if test="$attrs != ''">
                <xsl:value-of select="concat($SP, normalize-space($attrs))"/>
            </xsl:if>
            <xsl:value-of select="$TEc"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="capitalize">
    <xsl:param name="value"/>
    <xsl:value-of select="translate($value,
                                    '_abcdefghijklmnopqrstuvwrxyz',
                                    '-ABCDEFGHIJKLMNOPQRSTUVWRXYZ')"/>
</xsl:template>


<!--
  proceed
  -->

<xsl:template match="/resource-agent">
    <xsl:value-of select="$NL"/>

    <!-- define name=... (start) -->
    <xsl:variable name="capitalized">
        <xsl:call-template name="capitalize">
            <xsl:with-param name="value" select="@name"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="tag-start">
        <xsl:with-param name="name" select="'define'"/>
        <xsl:with-param name="attrs" select="concat(
            'name=', $Q, $capitalized, $Q)"/>
    </xsl:call-template>
    <xsl:value-of select="$NL"/>

        <!-- element name=... rha:description=... (start) -->
        <xsl:call-template name="tag-start">
            <xsl:with-param name="name" select="'element'"/>
            <xsl:with-param name="attrs" select="concat(
                'name=',            $Q, @name,                      $Q, $SP,
                'rha:description=', $Q, normalize-space(shortdesc), $Q)"/>
            <xsl:with-param name="indented"
                            select="$global-init-indent"/>
        </xsl:call-template>
        <xsl:value-of select="$NL"/>

            <!-- choice (start) -->
            <xsl:call-template name="tag-start">
                <xsl:with-param name="name" select="'choice'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

                <!-- group (start) -->
                <xsl:call-template name="tag-start">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

                    <!-- (comment) -->
                    <xsl:call-template name="comment">
                        <xsl:with-param name="text">
                            <xsl:text>rgmanager specific stuff</xsl:text>
                        </xsl:with-param>
                        <xsl:with-param name="indented"
                                        select="concat($global-init-indent,
                                                       $global-indent,
                                                       $global-indent,
                                                       $global-indent)"/>
                    </xsl:call-template>
                    <xsl:value-of select="$NL"/>

                    <!-- attribute name="ref" -->
                    <xsl:call-template name="tag">
                        <xsl:with-param name="name" select="'attribute'"/>
                        <xsl:with-param name="attrs" select="concat(
                            'name=',            $Q, 'ref',                    $Q, $SP,
                            'rha:description=', $Q, 'Reference to existing ',
                                                    @name, ' resource in ',
                                                    'the resources section.', $Q)"/>
                        <xsl:with-param name="indented"
                                        select="concat($global-init-indent,
                                                       $global-indent,
                                                       $global-indent,
                                                       $global-indent)"/>
                    </xsl:call-template>
                    <xsl:value-of select="$NL"/>

                <!-- group (end) -->
                <xsl:call-template name="tag-end">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

                <!-- group (start) -->
                <xsl:call-template name="tag-start">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

                <xsl:for-each select="parameters/parameter">
                    <xsl:variable name="use-indented"
                                  select="concat($global-init-indent,
                                                 $global-indent,
                                                 $global-indent,
                                                 $global-indent,
                                                 substring($global-indent, 1,
                                                           number(not(@required = '1'
                                                                      or @primary = '1')) * 64))"/>
                    <xsl:if test="$use-indented != concat($global-init-indent,
                                                          $global-indent,
                                                          $global-indent,
                                                          $global-indent)">

                        <!-- optional (start) -->
                        <xsl:call-template name="tag-start">
                            <xsl:with-param name="name" select="'optional'"/>
                            <xsl:with-param name="indented"
                                            select="concat($global-init-indent,
                                                           $global-indent,
                                                           $global-indent,
                                                           $global-indent)"/>
                        </xsl:call-template>
                        <xsl:value-of select="$NL"/>

                    </xsl:if>

                    <!-- attribute name=... rha:description=... -->
                    <xsl:call-template name="tag">
                        <xsl:with-param name="name" select="'attribute'"/>
                        <xsl:with-param name="attrs" select="concat(
                            'name=',            $Q, @name,                      $Q, $SP,
                            'rha:description=', $Q, normalize-space(shortdesc), $Q)"/>
                        <xsl:with-param name="indented" select="$use-indented"/>
                        <xsl:with-param name="fill-with"
                                        select="document('')/*/int:agent-parameter-specialization
                                                /int:agent[
                                                    @name = current()/../../@name
                                                ]/int:parameter[
                                                    @name = current()/@name
                                                ]/*"/>
                    </xsl:call-template>
                    <xsl:value-of select="$NL"/>

                    <xsl:if test="$use-indented != concat($global-init-indent,
                                                          $global-indent,
                                                          $global-indent,
                                                          $global-indent)">

                            <!-- optional (end) -->
                            <xsl:call-template name="tag-end">
                                <xsl:with-param name="name" select="'optional'"/>
                                <xsl:with-param name="indented"
                                                select="concat($global-init-indent,
                                                               $global-indent,
                                                               $global-indent,
                                                               $global-indent)"/>
                            </xsl:call-template>
                            <xsl:value-of select="$NL"/>

                    </xsl:if>
                </xsl:for-each>

                <!-- group (end) -->
                <xsl:call-template name="tag-end">
                    <xsl:with-param name="name" select="'group'"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

            <!-- choice (end) -->
            <xsl:call-template name="tag-end">
                <xsl:with-param name="name" select="'choice'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

            <xsl:call-template name="tag">
                <xsl:with-param name="name" select="'ref'"/>
                <xsl:with-param name="attrs" select="concat(
                    'name=', $Q, 'RESOURCECOMMONPARAMS', $Q)"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

            <!-- optional (start) -->
            <xsl:call-template name="tag-start">
                <xsl:with-param name="name" select="'optional'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

                <!-- ref name="CHILDREN" -->
                <xsl:call-template name="tag">
                    <xsl:with-param name="name" select="'ref'"/>
                    <xsl:with-param name="attrs" select="concat(
                        'name=', $Q, 'CHILDREN', $Q)"/>
                    <xsl:with-param name="indented"
                                    select="concat($global-init-indent,
                                                   $global-indent,
                                                   $global-indent)"/>
                </xsl:call-template>
                <xsl:value-of select="$NL"/>

            <!-- optional (end) -->
            <xsl:call-template name="tag-end">
                <xsl:with-param name="name" select="'optional'"/>
                <xsl:with-param name="indented"
                                select="concat($global-init-indent,
                                               $global-indent)"/>
            </xsl:call-template>
            <xsl:value-of select="$NL"/>

        <!-- element (end) -->
        <xsl:call-template name="tag-end">
            <xsl:with-param name="name" select="'element'"/>
            <xsl:with-param name="indented"
                            select="$global-init-indent"/>
        </xsl:call-template>
        <xsl:value-of select="$NL"/>

    <!-- define (end) -->
    <xsl:call-template name="tag-end">
        <xsl:with-param name="name" select="'define'"/>
    </xsl:call-template>
    <xsl:value-of select="$NLNL"/>

</xsl:template>

</xsl:stylesheet>
